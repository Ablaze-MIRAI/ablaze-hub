class FlowsController < ApplicationController

  def registration
    flow_id = params[:flow]
    if not flow_id
      kratos_url = ENV['KRATOS_PUBLIC_URL']
      full_url = "#{kratos_url}/self-service/registration/browser"
      response = HTTP.headers(:accept => "application/json").get(full_url)

      token = get_csrf_token(response)

      cookies[:csrf_token] = {
        :value => token,
        :expires => 1.hour.from_now
      }
      @flow_id = JSON.parse(response.body)["id"]
      @response = JSON.pretty_generate(JSON.parse(response.body))

    else
      kratos_url = ENV['KRATOS_PUBLIC_URL']
      full_url = "#{kratos_url}/self-service/registration/flows?id=#{flow_id}"
      token = cookies[:csrf_token]
      response = HTTP
                   .headers(:accept => "application/json")
                    .headers("X-CSRF-Token" => token)
                   .get(full_url)
      @response = JSON.pretty_generate(JSON.parse(response.body))
    end
  end

  def login
  end

  private

  def get_csrf_token(response)
    nodes = JSON.parse(response.body)["ui"]["nodes"]
    csrf_token = nil
    nodes.each do |node|
      if node["attributes"]["name"] == "csrf_token"
        csrf_token = node["attributes"]["value"]
      end
    end
    csrf_token
  end
end
