class ApplicationController < ActionController::Base
  before_action :get_logout
  def index

  end

  private

  def get_logout
    kratos_url = ENV['KRATOS_PUBLIC_URL']
    return_to = params[:return_to] || root_url
    response = helpers.get("#{kratos_url}/self-service/logout/browser?return_to=#{return_to}")
    if helpers.is_logged_in? && response.status == 200
      @logout_token = response.parse["logout_token"]
      @logout_url = "/logout?token=#{@logout_token}&return_to=#{return_to}"
    end
  end

end
