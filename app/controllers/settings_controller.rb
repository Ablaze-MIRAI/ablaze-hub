class SettingsController < ApplicationController
  layout 'settings'

  def index
    render :profile
  end

  def profile
    avatar = @user.avatar.variant(resize_to_limit: [100, 100])
    @avatar_url = Rails.application.routes.url_helpers.rails_representation_url(avatar, only_path: true)
  end

  def update_profile
    @user.avatar.attach(params[:avatar]) if params[:avatar].present?
    redirect_to settings_profile_path, notice: 'Profile updated'
  end

  def admin
  end

  def appearance
  end

  def sessions
    response = helpers.get("#{@kratos}/sessions")
    @sessions = response.parse
  end

  def security
  end
end
