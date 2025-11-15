class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Generate a new OTP secret for the user
  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random
    save
  end

  # Get the provisioning URI for QR code generation
  def provisioning_uri
    return nil unless otp_secret.present?
    ROTP::TOTP.new(otp_secret, issuer: "Two Factor App").provisioning_uri(email)
  end

  # Verify the TOTP code entered by the user
  def verify_totp(code)
    return false unless otp_secret.present? && code.present?
    begin
      totp = ROTP::TOTP.new(otp_secret)
      result = totp.verify(code.to_s, drift_behind: 15, drift_ahead: 15)
      # ROTP returns timestamp (truthy) when valid, nil when invalid
      !!result
    rescue ArgumentError
      false
    end
  end

  # Check if 2FA is enabled and verified
  def two_factor_required?
    two_factor_enabled? && !two_factor_verified?
  end
end
