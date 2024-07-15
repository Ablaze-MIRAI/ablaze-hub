class ApplicationController < ActionController::Base
  def index
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    cookie_str = cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
    session_response = HTTP
                         .headers("Content-Type" => "application/json")
                         .headers("Accept" => "application/json")
                         .headers("Cookie" => cookie_str)
                         .get("#{kratos_url}/sessions")

    @sessions = []
    if session_response.status == 200
      @sessions = session_response.parse.map do |session|
        SessionResponse.new(session)
      end
      @raw_sessions = JSON.pretty_generate(session_response.parse)
    end
  end
end
