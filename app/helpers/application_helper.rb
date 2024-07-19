module ApplicationHelper
  def get(url)
    cookie_string = cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
    HTTP.headers("Cookie" => cookie_string)
        .headers(:accept => "application/json")
        .get(url)
  end

  def post(url, body)
    HTTP
      .headers("Content-Type" => "application/json")
      .headers("X-Forwarded-For" => request.remote_ip)
      .headers("User-Agent" => request.user_agent)
      .headers("Cookie" => cookies.map { |k, v| "#{k}=#{v}" }.join("; "))
      .post(url, :json => body)
  end
end
