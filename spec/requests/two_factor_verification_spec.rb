require 'rails_helper'

RSpec.describe "Two Factor Verification", type: :request do
  let(:user) { create(:user, :with_two_factor) }
  let(:totp) { ROTP::TOTP.new(user.otp_secret) }

  before do
    sign_in user
  end

  describe "GET /two_factor_verification" do
    it "returns http success" do
      get two_factor_verification_path
      expect(response).to have_http_status(:success)
    end

    it "displays verification form" do
      get two_factor_verification_path
      expect(response.body).to include("Verification Code")
    end

    context "when 2FA is not enabled" do
      let(:user) { create(:user) }

      it "redirects to setup" do
        get two_factor_verification_path
        expect(response).to redirect_to(two_factor_setup_path)
      end
    end

    context "when not authenticated" do
      before do
        sign_out user
      end

      it "redirects to sign in" do
        get two_factor_verification_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /two_factor_verification/verify" do
    context "with valid code" do
      it "verifies 2FA" do
        code = totp.now
        post two_factor_verification_verify_path, params: { code: code }
        user.reload
        expect(user.two_factor_verified).to be true
      end

      it "redirects to home" do
        code = totp.now
        post two_factor_verification_verify_path, params: { code: code }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid code" do
      it "does not verify 2FA" do
        post two_factor_verification_verify_path, params: { code: "000000" }
        user.reload
        expect(user.two_factor_verified).to be false
      end

      it "renders show with error" do
        post two_factor_verification_verify_path, params: { code: "000000" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
