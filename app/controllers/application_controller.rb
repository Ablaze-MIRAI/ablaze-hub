class ApplicationController < ActionController::Base
  def index
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    session_response = HTTP
                         .headers("Content-Type" => "application/json")
                         .headers("Accept" => "application/json")
                         .headers("Cookie" => get_cookie_str)
                         .get("#{kratos_url}/sessions")

    @sessions = []
    if session_response.status == 200
      _sessions = session_response.parse
      if _sessions.length == 0
        cookies.delete("ory_kratos_session")
        redirect_to "/"
      end
      @sessions = session_response.parse.map do |session|
        SessionResponse.new(session)
      end
      @raw_sessions = JSON.pretty_generate(session_response.parse)
    end
  end

  def whoami
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    response = HTTP
                 .headers("Content-Type" => "application/json")
                 .headers("Content-Type" => "application/json")
                 .headers("Cookie" => get_cookie_str)
                 .get("#{kratos_url}/sessions/whoami")

    if response.status == 200
      @raw_response = JSON.pretty_generate(response.parse)
    end
  end

  private

  def get_sessions

  end

  def get_cookie_str
    cookies.map { |k, v| "#{k}=#{v}=" }.join("; ")
  end
end
