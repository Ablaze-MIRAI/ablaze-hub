class SettingsController < ApplicationController
  layout 'settings'
  before_action :authenticate_user!

  def index
  end

  def profile
  end

  def admin
  end

  def appearance
  end

  def sessions
  end

  def security
  end

  private

  def authenticate_user!
    redirect_to "#{login_path}?return_to=#{request.url}" unless helpers.is_logged_in?
  end
end
