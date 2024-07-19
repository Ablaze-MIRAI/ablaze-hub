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

  private

  def get_cookie_str
    cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
  end
end
