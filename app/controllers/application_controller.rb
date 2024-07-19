class ApplicationController < ActionController::Base
  before_action :get_logout
  before_action :kratos_url

  # Authenticate user and get user identity before every action except application#index
  before_action :authenticate_user!, unless: -> { action_name == 'index' && self.class == ApplicationController }
  before_action :get_user_identity, unless: -> { action_name == 'index' && self.class == ApplicationController }

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

  def kratos_url
    @kratos = ENV['KRATOS_PUBLIC_URL']
    @kratos_admin = ENV['KRATOS_ADMIN_URL']
  end

  def get_user_identity
    identity = helpers.get("#{ENV['KRATOS_PUBLIC_URL']}/sessions/whoami")
    if identity.status == 401
      redirect_to "#{login_path}?return_to=#{request.url}"
    end
    @identity = identity.parse
    @public_metadata = @identity["metadata_public"]
    @username = @identity["identity"]["traits"]["username"]
    @email = @identity["identity"]["traits"]["email"]
    @user = User.find_or_create(@identity["identity"])
  end

  def authenticate_user!
    redirect_to "#{login_path}?return_to=#{request.url}" unless helpers.is_logged_in?
  end
end
