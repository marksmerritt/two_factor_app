class TwoFactorVerificationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_two_factor_setup

  def show
    # Show verification form
  end

  def verify
    if current_user.verify_totp(params[:code])
      current_user.update(two_factor_verified: true)
      redirect_to root_path, notice: "Two-factor authentication verified successfully!"
    else
      flash.now[:alert] = "Invalid code. Please try again."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def require_two_factor_setup
    unless current_user.two_factor_enabled?
      redirect_to two_factor_setup_path, alert: "Please set up two-factor authentication first."
    end
  end
end

