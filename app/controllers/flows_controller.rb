class FlowsController < ApplicationController

  def registration
    flow_id = params[:flow]
    fetch_flow(flow_id, "registration", registration_path)
  end

  def registration_submit
    form_data = params
    handle_submit(form_data, "registration", :registration)
  end

  def login
    flow_id = params[:flow]
    _params = {
    }
    _params[:return_to] = params[:return_to] if params[:return_to]
    _params[:refresh] = params[:refresh] if params[:refresh]
    _params[:via] = params[:via] if params[:via]
    _params[:login_challenge] = params[:login_challenge] if params[:login_challenge]
    _params[:aal] = params[:aal] if params[:aal]
    fetch_flow(flow_id, "login", login_path, _params)
  end

  def login_submit
    form_data = params
    handle_submit(form_data, "login", :login)
  end

  def logout
    token = params[:token]
    return_to = params[:return_to] || root_url

    if token.nil? || cookies[:ory_kratos_session].nil?
      redirect_to return_to
      return
    end

    full = "#{ENV['KRATOS_PUBLIC_URL']}/self-service/logout?token=#{token}&return_to=#{return_to}"
    response = helpers.get(full)
    if response.status == 204
      cookies.delete :ory_kratos_session
    elsif response.status == 401
      if cookies[:ory_kratos_session]
        cookies.delete :ory_kratos_session
      end
    end

    redirect_to return_to
  end

  def errors
    error_id = params[:id]
    full = "#{ENV['KRATOS_PUBLIC_URL']}/self-service/errors?id=#{error_id}"
    response = helpers.get(full)
    @flow_type = "registration"
    @error = JSON.pretty_generate(response.parse)
  end

  private

  def fetch_flow(flow_id, flow_type, submit_path, query_params = nil)
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    if flow_id
      full_url = "#{kratos_url}/self-service/#{flow_type}/flows?id=#{flow_id}"
      response = helpers.get(full_url)
      if response.status == 410
        @error = JSON.pretty_generate(response.parse)
        @flow_type = flow_type
        render :errors
        return
      end
      if response.status == 400
        redirect_to "/#{flow_type}?flow=#{response.parse["id"]}"
        return
      end

      if response.status == 303
        redirect_to response.headers["Location"]
        return
      end
      @submit_path = submit_path
      @flow = response.parse
      return
    end

    full_url = "#{kratos_url}/self-service/#{flow_type}/browser?#{get_query_params(query_params)}"
    response = helpers.get(full_url)
    set_cookie(response)
    redirect = response.headers["Location"] || "/#{flow_type}?flow=#{response.parse["id"]}"
    redirect_to redirect
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

  def handle_submit(form_data, flow_type, render_path)
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    action_url = form_data["action_url"]
    flow_id = action_url.split("/").last.split("?").last.split("=").last
    full_url = "#{kratos_url}/self-service/#{flow_type}/flows?id=#{flow_id}"
    flow_res = helpers.get(full_url)
    response = helpers.post(action_url, form_data)
    if response.status == 200
      set_cookie(response)
      return_to = flow_res.parse["return_to"] || root_url
      redirect_to return_to
    elsif response.status == 400
      redirect_to "/#{flow_type}?flow=#{response.parse["id"]}"
    elsif response.status == 422
      url = response.parse["redirect_browser_to"]
      set_cookie(response)
      @redirect_url = url
      render render_path, :status => 422
    elsif response.status == 303
      redirect_to response.headers["Location"]
    else
      @error = JSON.pretty_generate(response.parse)
      @flow_type = flow_type
    end
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
      cookie_options[:max_age] = Time.now + max_age if max_age
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

  def get_ui_nodes(body)
    JSON.parse(body)["ui"]["nodes"]
  end
end
