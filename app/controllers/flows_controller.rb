class FlowsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :get_user_identity

  def registration
    flow_id = params[:flow]
    _params = {}
    _params[:return_to] = params[:return_to] if params[:return_to]
    _params[:login_challenge] = params[:login_challenge] if params[:login_challenge]
    _params[:after_verification_return_to] = params[:after_verification_return_to] if params[:after_verification_return_to]
    fetch_flow(flow_id, "registration", registration_path, _params)
  end

  def registration_submit
    form_data = params
    handle_submit(form_data, "registration", :registration)
  end

  def login
    flow_id = params[:flow]
    _params = {}
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

  def recovery
    flow_id = params[:flow]
    _params = {}
    _params[:return_to] = params[:return_to] if params[:return_to]
    fetch_flow(flow_id, "recovery", recovery_path, _params)
  end

  def recovery_submit

  end

  def verification
    flow_id = params[:flow]
    _params = {}
    _params[:return_to] = params[:return_to] if params[:return_to]
    fetch_flow(flow_id, "verification", verification_path, _params)
  end

  def verification_submit

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
    if flow_id
      full_url = "#{@kratos}/self-service/#{flow_type}/flows?id=#{flow_id}"
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

    full_url = "#{@kratos}/self-service/#{flow_type}/browser?#{helpers.get_query_params(query_params)}"
    response = helpers.get(full_url)
    helpers.set_cookie(response)
    redirect = response.headers["Location"] || "/#{flow_type}?flow=#{response.parse["id"]}"
    redirect_to redirect
  end

  def handle_submit(form_data, flow_type, render_path)
    action_url = form_data["action_url"]
    flow_id = action_url.split("/").last.split("?").last.split("=").last
    full_url = "#{@kratos}/self-service/#{flow_type}/flows?id=#{flow_id}"
    flow_res = helpers.get(full_url)
    response = helpers.post(action_url, form_data)
    if response.status == 200
      helpers.set_cookie(response)
      return_to = flow_res.parse["return_to"] || root_url
      redirect_to return_to
    elsif response.status == 400
      redirect_to "/#{flow_type}?flow=#{response.parse["id"]}"
    elsif response.status == 422
      url = response.parse["redirect_browser_to"]
      helpers.set_cookie(response)
      @redirect_url = url
      render render_path, :status => 422
    elsif response.status == 303
      redirect_to response.headers["Location"]
    else
      @error = JSON.pretty_generate(response.parse)
      @flow_type = flow_type
    end
  end
end
