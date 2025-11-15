require 'rails_helper'

RSpec.describe "Complete Two-Factor Authentication Flow", type: :request do
  let(:user) { create(:user, password: "password123") }

  describe "New user flow" do
    it "guides user through complete 2FA setup and verification" do
      # Step 1: User signs up
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
      user = User.find_by(email: "newuser@example.com")
      expect(user).to be_present
      expect(response).to redirect_to(root_path)

      # Step 2: User is redirected to 2FA setup
      follow_redirect!
      expect(response).to redirect_to(two_factor_setup_path)
      follow_redirect!

      # Step 3: User sees QR code
      expect(response).to have_http_status(:success)
      expect(response.body).to include("svg")
      user.reload
      expect(user.otp_secret).to be_present

      # Step 4: User enables 2FA with valid code
      totp = ROTP::TOTP.new(user.otp_secret)
      code = totp.now
      post two_factor_setup_enable_path, params: { code: code }
      user.reload
      expect(user.two_factor_enabled).to be true
      expect(user.two_factor_verified).to be true
      expect(response).to redirect_to(root_path)

      # Step 5: User can access home page
      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end

  describe "Returning user flow" do
    let(:user) { create(:user, :with_two_factor, password: "password123") }
    let(:totp) { ROTP::TOTP.new(user.otp_secret) }

    it "requires 2FA verification after login" do
      # Step 1: User signs in
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }
      user.reload
      expect(user.two_factor_verified).to be false
      expect(response).to redirect_to(root_path)

      # Step 2: User is redirected to 2FA verification
      follow_redirect!
      expect(response).to redirect_to(two_factor_verification_path)
      follow_redirect!

      # Step 3: User enters verification code
      code = totp.now
      post two_factor_verification_verify_path, params: { code: code }
      user.reload
      expect(user.two_factor_verified).to be true
      expect(response).to redirect_to(root_path)

      # Step 4: User can access home page
      follow_redirect!
      expect(response).to have_http_status(:success)
    end

    it "blocks access until 2FA is verified" do
      sign_in user
      
      # Try to access home without verification
      get root_path
      expect(response).to redirect_to(two_factor_verification_path)

      # Verify 2FA
      code = totp.now
      post two_factor_verification_verify_path, params: { code: code }

      # Now can access home
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "Invalid code handling" do
    let(:user) { create(:user, otp_secret: ROTP::Base32.random) }

    before do
      sign_in user
    end

    it "rejects invalid codes during setup" do
      get two_factor_setup_path
      post two_factor_setup_enable_path, params: { code: "000000" }
      user.reload
      expect(user.two_factor_enabled).to be false
      expect(response).to redirect_to(two_factor_setup_path)
    end

    it "rejects invalid codes during verification" do
      user.update(two_factor_enabled: true)
      get two_factor_verification_path
      post two_factor_verification_verify_path, params: { code: "000000" }
      user.reload
      expect(user.two_factor_verified).to be false
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

