class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :require_two_factor_verification

  private

  def require_two_factor_verification
    # Skip 2FA check for Devise routes and 2FA setup/verification routes
    return if devise_controller?
    return if controller_name == 'two_factor_setup' || controller_name == 'two_factor_verification'

    # Only require 2FA if the user has the flag set to true
    return unless user_signed_in? && current_user.two_factor_auth_required?

    # If user has 2FA enabled but not verified, redirect to verification
    if current_user.two_factor_enabled? && !current_user.two_factor_verified?
      redirect_to two_factor_verification_path, alert: "Please verify your two-factor authentication code."
    end
  end
end

