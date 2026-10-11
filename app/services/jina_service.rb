require 'net/http'
require 'uri'

class JinaService
  JINA_BASE_URL = 'https://r.jina.ai'

  class Error < StandardError
    attr_reader :status

    def initialize(status)
      @status = status.to_i
      super("Jina.ai returned HTTP #{@status}")
    end
  end

  def fetch_markdown(url)
    jina_uri = URI.parse("#{JINA_BASE_URL}/#{url}")
    authenticated = ENV['JINA_API_KEY'].present?
    Rails.logger.debug "Jina.ai fetching URL: #{url} (authenticated: #{authenticated})"

    http = Net::HTTP.new(jina_uri.host, jina_uri.port)
    http.use_ssl = (jina_uri.scheme == 'https')
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(jina_uri)
    request['Accept'] = 'text/plain'

    if authenticated
      request['Authorization'] = "Bearer #{ENV['JINA_API_KEY']}"
    end

    response = http.request(request)
    Rails.logger.debug "Jina.ai response: HTTP #{response.code}, body length: #{response.body&.length} chars"

    unless response.is_a?(Net::HTTPSuccess)
      raise Error.new(response.code)
    end

    response.body
  end
end
