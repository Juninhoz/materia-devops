class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!

  private

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
