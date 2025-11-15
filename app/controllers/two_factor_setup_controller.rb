class TwoFactorSetupController < ApplicationController
  before_action :authenticate_user!

  def show
    # Generate OTP secret if user doesn't have one
    current_user.generate_otp_secret unless current_user.otp_secret.present?

    # Generate QR code
    qr = RQRCode::QRCode.new(current_user.provisioning_uri)
    @qr_code_svg = qr.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    )
  end

  def enable
    if current_user.verify_totp(params[:code])
      current_user.update(two_factor_enabled: true, two_factor_verified: true)
      redirect_to root_path, notice: "Two-factor authentication has been enabled successfully!"
    else
      redirect_to two_factor_setup_path, alert: "Invalid code. Please try again."
    end
  end
end
