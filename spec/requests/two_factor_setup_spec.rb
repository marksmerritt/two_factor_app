require 'rails_helper'

RSpec.describe "Two Factor Setup", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /two_factor_setup" do
    it "returns http success" do
      get two_factor_setup_path
      expect(response).to have_http_status(:success)
    end

    it "displays the QR code" do
      get two_factor_setup_path
      expect(response.body).to include("svg")
    end

    it "displays the OTP secret" do
      get two_factor_setup_path
      user.reload
      expect(response.body).to include(user.otp_secret)
    end

    context "when not authenticated" do
      before do
        sign_out user
      end

      it "redirects to sign in" do
        get two_factor_setup_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /two_factor_setup/enable" do
    let(:user) { create(:user, otp_secret: ROTP::Base32.random) }
    let(:totp) { ROTP::TOTP.new(user.otp_secret) }

    context "with valid code" do
      it "enables 2FA" do
        code = totp.now
        post two_factor_setup_enable_path, params: { code: code }
        user.reload
        expect(user.two_factor_enabled).to be true
        expect(user.two_factor_verified).to be true
      end

      it "redirects to home" do
        code = totp.now
        post two_factor_setup_enable_path, params: { code: code }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid code" do
      it "does not enable 2FA" do
        post two_factor_setup_enable_path, params: { code: "000000" }
        user.reload
        expect(user.two_factor_enabled).to be false
      end

      it "redirects back with error" do
        post two_factor_setup_enable_path, params: { code: "000000" }
        expect(response).to redirect_to(two_factor_setup_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
