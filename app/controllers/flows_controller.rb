class FlowsController < ApplicationController

  def registration
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    flow_id = params[:flow]

    if flow_id
      full_url = "#{kratos_url}/self-service/registration/flows?id=#{flow_id}"
      _cookies = cookies.to_h
      response = HTTP.headers("Cookie" => _cookies).get(full_url)
      @status = response.status
      @response = JSON.pretty_generate(JSON.parse(response.body))
      return
    end

    full_url = "#{kratos_url}/self-service/registration/browser?"
    response = HTTP.get(full_url)
    @status = response.status
    @response = JSON.pretty_generate(JSON.parse(response.body))
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
