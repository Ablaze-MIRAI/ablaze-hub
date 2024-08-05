module FlowsHelper
  ##
  # Returns the style classes for a given type.
  def get_style_classes(type)
    case type
    when "submit"
      return "btn btn-primary"
    else
      return ""
    end
  end

  def is_logged_in?
    if cookies["ory_kratos_session"].blank?
      return false
    end

    kratos_url = ENV['KRATOS_PUBLIC_URL']
    response = HTTP
                 .headers("Content-Type" => "application/json")
                 .headers("Content-Type" => "application/json")
                 .headers("Cookie" => get_cookie_str)
                 .get("#{kratos_url}/sessions/whoami")

    if response.status == 200
      # get ory_kratos_session cookie anc check if it is present and still not expired
      identity = response.parse
      if identity.present? && identity["expires_at"].present? && identity["expires_at"] > Time.now
        return identity["active"] == true
      end
    end

    false
  end

  def get_query_params(params)
    if params.nil?
      return ""
    end
    query_params = ""
    params.each do |key, value|
      query_params += "#{key}=#{value}&"
    end
    query_params[0..-2]
  end

  def set_cookie(response)
    response_headers = response.headers
    set_cookies = response_headers["Set-Cookie"]
    return unless set_cookies
    _set_cookies = []
    if set_cookies.is_a?(String)
      _set_cookies << set_cookies
    else
      _set_cookies = set_cookies
    end

    _set_cookies.each do |set_cookie|
      cookie = set_cookie.split(";")
      cookie_name = cookie[0].split("=")[0]
      cookie_value = cookie[0].split("=", 2)[1]
      path = get_property_from_cookie(cookie, "Path")
      max_age = get_property_from_cookie(cookie, "Max-Age")
      max_age = max_age.to_i if max_age
      http_only = get_property_from_cookie(cookie, "HttpOnly", true)
      http_only = http_only != nil

      cookie_options = {}
      cookie_options[:path] = path if path
      cookie_options[:expires] = Time.now + max_age if max_age
      cookie_options[:http_only] = http_only if http_only
      cookie_options[:value] = cookie_value
      cookie_name_sym = cookie_name.to_sym
      cookies[cookie_name_sym] = cookie_options
    end
  end

  def get_property_from_cookie(cookie, property, only_present = false)
    cookie.each do |c|
      if c.include?(property)
        if only_present
          return true
        end
        return c.split("=")[1]
      end
    end
    nil
  end


  ##
  # Returns a boolean value if the flow has a back node. It has back node if the value of a node has a `something:back` value
  def has_back_node?(flow)
    get_back_node(flow).present?
  end

  ##
  # Returns a node if the flow has a back node. It has back node if the value of a node has a `something:back` value
  # @param [Hash] flow The flow object
  def get_back_node(flow)
    flow["ui"]["nodes"].each do |node|
      if is_back_node?(node)
        return node
      end
    end
    nil
  end

  def is_back_node?(node)
    if node["attributes"].nil? || node["attributes"]["value"].nil?
      return false
    end
    value = node["attributes"]["value"]

    if value.end_with?(":back") || value == "credential-selection"
      return true
    end

    false
  end

  private

  def get_cookie_str
    cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
  end
end
