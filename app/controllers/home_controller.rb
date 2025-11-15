class HomeController < ApplicationController
  def index
    # Redirect to 2FA setup if 2FA is required but user hasn't enabled it yet
    if user_signed_in? && current_user.two_factor_auth_required? && !current_user.two_factor_enabled?
      redirect_to two_factor_setup_path, notice: "Please set up two-factor authentication to continue."
    end
  end
end

