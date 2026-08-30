require 'net/http'
require 'uri'
require 'resolv'
require 'ipaddr'

# Detects the main picture of a recipe page and downloads it.
#
# The Jina.ai markdown used for text extraction is not usable here: on several
# Swiss recipe platforms it drops the hero image entirely (Betty Bossi returns
# only promo teasers, Swissmilk returns no images at all), so this service
# fetches the raw HTML itself.
#
# Structured metadata is tried first and covers the common platforms without any
# AI call. Only when that yields nothing do we fall back to asking the configured
# AI engine to pick among the <img> candidates found in the page.
class RecipeImageDetector
  Candidate = Struct.new(:url, :source, :width, :alt, keyword_init: true) do
    def structured?
      source != :img
    end
  end

  USER_AGENT = 'Mozilla/5.0 (compatible; Reeper recipe importer)'.freeze
  MAX_HTML_BYTES = 2 * 1024 * 1024
  MAX_IMAGE_BYTES = 10 * 1024 * 1024
  MAX_REDIRECTS = 3
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  SOURCE_PRIORITY = { json_ld: 0, og: 1, twitter: 2, img: 3 }.freeze

  # Images that are never the dish, matched against the url and the alt text.
  JUNK_PATTERN = /logo|icon|sprite|avatar|placeholder|banner|badge|pixel|spinner|favicon|tracking/i
  # Width hints embedded in cdn urls, e.g. cloudinary "w_1200", migros
  # "v-w-1200-h-630", fooby "1200-800", generic "1200x630".
  WIDTH_HINT_PATTERNS = [/[?&_-]w[_-](\d{2,4})/i, /(\d{3,4})x\d{3,4}/, /_(\d{3,4})-\d{3,4}/].freeze
  MIN_IMG_WIDTH = 400

  def initialize(ai_method: nil)
    @ai_method = ai_method
  end

  # Returns { url:, io:, content_type:, filename: } or nil.
  # Never raises - a failed image detection must not break the text import.
  def detect(page_url)
    _content_type, html = fetch_body(page_url, MAX_HTML_BYTES)
    return nil if html.blank?

    candidates = extract_candidates(html, page_url)
    return nil if candidates.empty?

    chosen = choose(candidates)
    return nil if chosen.nil?

    download(chosen.url)
  rescue => e
    Rails.logger.warn "Recipe image detection failed for #{page_url}: #{e.class}: #{e.message}"
    nil
  end

  # Returns the image candidates found in the page, best first.
  def extract_candidates(html, page_url)
    doc = Nokogiri::HTML(html)

    candidates = json_ld_candidates(doc) + meta_candidates(doc) + img_candidates(doc)
    candidates = candidates.filter_map { |c| normalize(c, page_url) }
    candidates = deduplicate(candidates)

    structured = candidates.select(&:structured?)
    return sort_candidates(structured) if structured.any?

    sort_candidates(candidates)
  end

  private

  def choose(candidates)
    return candidates.first if candidates.first.structured?

    ai_pick(candidates)
  end

  # --- candidate extraction -------------------------------------------------

  def json_ld_candidates(doc)
    doc.css('script[type="application/ld+json"]').flat_map do |script|
      begin
        parsed = JSON.parse(script.text.to_s.strip)
      rescue JSON::ParserError => e
        Rails.logger.debug "Skipping malformed JSON-LD block: #{e.message}"
        next []
      end

      recipe_nodes(parsed).flat_map do |node|
        image_urls(node['image']).map { |url| Candidate.new(url: url, source: :json_ld) }
      end
    end
  end

  # Recipe nodes can sit at the top level, in an array, or inside an @graph.
  def recipe_nodes(parsed)
    nodes = case parsed
            when Array then parsed
            when Hash then parsed['@graph'].is_a?(Array) ? parsed['@graph'] : [parsed]
            else []
            end

    nodes.select { |node| node.is_a?(Hash) && Array(node['@type']).join(' ').include?('Recipe') }
  end

  # schema.org image can be a String, an ImageObject, or an array of either.
  def image_urls(image)
    case image
    when String then [image]
    when Array then image.flat_map { |entry| image_urls(entry) }
    when Hash then image_urls(image['url'] || image['contentUrl'])
    else []
    end
  end

  def meta_candidates(doc)
    [
      ['og:image:secure_url', :og], ['og:image', :og],
      ['twitter:image', :twitter], ['twitter:image:src', :twitter]
    ].flat_map do |name, source|
      doc.css("meta[property='#{name}'], meta[name='#{name}']").map do |meta|
        Candidate.new(url: meta['content'], source: source)
      end
    end
  end

  def img_candidates(doc)
    doc.css('img').filter_map do |img|
      url = img['src'].presence || largest_from_srcset(img['srcset'])
      next if url.blank?

      declared = img['width'].to_i
      next if declared.positive? && declared < 100
      next if img['height'].to_i.positive? && img['height'].to_i < 100

      alt = img['alt'].to_s
      next if "#{url} #{alt}".match?(JUNK_PATTERN)

      Candidate.new(url: url, source: :img, width: declared.positive? ? declared : nil, alt: alt)
    end
  end

  def largest_from_srcset(srcset)
    return nil if srcset.blank?

    srcset.split(',').map(&:strip).max_by { |entry| entry[/(\d+)w/, 1].to_i }&.split(/\s+/)&.first
  end

  # --- ranking --------------------------------------------------------------

  def normalize(candidate, page_url)
    return nil if candidate.url.blank?

    absolute = URI.join(page_url, candidate.url.strip).to_s
    return nil unless absolute.start_with?('http://', 'https://')

    candidate.url = absolute
    candidate.width ||= width_hint(absolute)
    candidate
  rescue URI::Error, ArgumentError
    nil
  end

  def width_hint(url)
    WIDTH_HINT_PATTERNS.each do |pattern|
      match = url[pattern, 1]
      return match.to_i if match
    end
    nil
  end

  def deduplicate(candidates)
    candidates.uniq(&:url)
  end

  # Largest known width wins - this is what picks Migros' 1200px og:image over
  # its 330px JSON-LD crops. Unknown widths fall back to source priority, which
  # keeps the semantically-correct JSON-LD recipe image ahead of a social crop.
  def sort_candidates(candidates)
    candidates.sort_by { |c| [-(c.width || 0), SOURCE_PRIORITY.fetch(c.source, 9)] }
  end

  # --- ai fallback ----------------------------------------------------------

  def ai_pick(candidates)
    shortlist = candidates.reject { |c| c.width && c.width < MIN_IMG_WIDTH }.first(12)
    shortlist = candidates.first(12) if shortlist.empty?

    payload = shortlist.map { |c| { url: c.url, alt: c.alt.to_s } }
    index = ai_service.select_main_image(payload)
    return nil unless index.is_a?(Integer) && index >= 0 && index < shortlist.length

    shortlist[index]
  end

  def ai_service
    @ai_service ||= @ai_method == 'openai_url' ? OpenaiService.new : MistralaiService.new
  end

  # --- fetching -------------------------------------------------------------

  def download(image_url)
    content_type, body = fetch_body(image_url, MAX_IMAGE_BYTES)
    mime = content_type.to_s.split(';').first.to_s.strip.downcase

    unless ALLOWED_IMAGE_TYPES.include?(mime)
      Rails.logger.info "Ignoring detected image #{image_url}: unsupported content type #{mime.presence || 'unknown'}"
      return nil
    end
    return nil if body.blank?

    { url: image_url, io: StringIO.new(body), content_type: mime, filename: filename_for(image_url, mime) }
  end

  def filename_for(image_url, mime)
    base = File.basename(URI.parse(image_url).path.to_s).presence || 'recipe-image'
    base = base.gsub(/[^\w.\-]/, '_')[0, 100]
    extension = { 'image/jpeg' => '.jpg', 'image/png' => '.png', 'image/webp' => '.webp' }.fetch(mime, '.jpg')
    base.end_with?(extension) ? base : "#{base}#{extension}"
  end

  # Returns [content_type, body]. Follows redirects and caps the response size.
  def fetch_body(url, max_bytes, redirects_left = MAX_REDIRECTS)
    uri = URI.parse(url)
    raise ArgumentError, "Unsupported scheme for #{url}" unless uri.is_a?(URI::HTTP)

    verify_public_host!(uri)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = 10
    http.read_timeout = 15

    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = USER_AGENT
    request['Accept'] = '*/*'

    http.request(request) do |response|
      if response.is_a?(Net::HTTPRedirection) && response['location'].present?
        raise "Too many redirects for #{url}" if redirects_left <= 0

        return fetch_body(URI.join(url, response['location']).to_s, max_bytes, redirects_left - 1)
      end
      raise "HTTP #{response.code} for #{url}" unless response.is_a?(Net::HTTPSuccess)

      body = +''
      response.read_body do |chunk|
        body << chunk
        raise "Response from #{url} exceeds #{max_bytes} bytes" if body.bytesize > max_bytes
      end

      return [response['content-type'], body]
    end
  end

  # A recipe page must not be able to point the importer at an internal address.
  def verify_public_host!(uri)
    addresses = Resolv.getaddresses(uri.host)
    raise "Could not resolve #{uri.host}" if addresses.empty?

    addresses.each do |address|
      ip = IPAddr.new(address)
      if ip.loopback? || ip.private? || ip.link_local?
        raise "Refusing to fetch non-public address #{address} for #{uri.host}"
      end
    end
  rescue IPAddr::InvalidAddressError
    raise "Could not validate host #{uri.host}"
  end
end
