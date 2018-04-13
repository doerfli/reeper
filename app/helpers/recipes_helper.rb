module RecipesHelper

  def with_url_links(string)
    md = %r{https?:\/\/[A-Za-z0-9\-\._~:\/\?\#%@!$&'\(\)\+,;\=`\.]+}.match(string)
    return string if md.nil?
    url = md[0]
    front = string[0...md.begin(0)]
    back = string[md.end(0)...string.size]
    "#{front}<a href=\"#{url}\" target=\"_blank\">#{url}</a>#{back}".html_safe
  end

end
