class FlowsController < ApplicationController

  def registration
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    flow_id = params[:flow]

    if flow_id
      full_url = "#{kratos_url}/self-service/registration/flows?id=#{flow_id}"
      response = fetch_content(full_url)
      if response.status == 410
        @error = JSON.pretty_generate(response.parse)
        @flow_type = "registration"
        render :error
        return
      end
      @submit_url = response.parse["ui"]["action"]
      @flow_id = flow_id
      @nodes = get_ui_nodes(response.body)
      return
    end

    full_url = "#{kratos_url}/self-service/registration/browser?"
    response = HTTP.get(full_url)
    set_cookie(response)
    redirect_to response.headers["Location"]
  end

  def registration_submit
    form_data = params
    action_url = form_data["action_url"]
    response = HTTP
                 .headers("Content-Type" => "application/json")
                 .headers("Cookie" => cookies.map { |k, v| "#{k}=#{v}=" }.join("; "))
                 .post(action_url, :json => form_data)
    if response.status == 200
      redirect_to root_path
    elsif response.status == 400
      redirect_to "/registration?flow=#{response.parse["id"]}"
    elsif response.status == 422
      url = response.parse["redirect_browser_to"]
      redirect_to url, allow_other_host: true
    elsif response.status == 303
      redirect_to response.headers["Location"]
    else
      @error = JSON.pretty_generate(response.parse)
      @flow_type = "registration"
    end
  end

  def login
  end

  def error
    flow_id = params[:flow]
    full = "#{ENV['KRATOS_PUBLIC_URL']}/self-service/errors?id=#{flow_id}"
    response = fetch_content(full)
    @flow_type = "registration"
    @error = JSON.pretty_generate(response.parse)
  end

  private

  def set_cookie(response)
    response_headers = response.headers
    set_cookie = response_headers["Set-Cookie"]
    split_cookie = set_cookie.split(";")
    cookie_name = split_cookie[0].split("=")[0]
    cookie_value = split_cookie[0].split("=")[1]
    cookie_name_sym = cookie_name.to_sym
    cookies[cookie_name_sym] = cookie_value
  end

  def get_ui_nodes(body)
    JSON.parse(body)["ui"]["nodes"]
  end

  def process_response(response, flow_type) end

  def fetch_content(url)
    cookie_string = cookies.map { |k, v| "#{k}=#{v}=" }.join("; ")
    HTTP.headers("Cookie" => cookie_string)
        .headers(:accept => "application/json")
        .get(url)
  end
end
