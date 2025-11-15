require 'rails_helper'

RSpec.describe TwoFactorVerificationController, type: :controller do
  let(:user) { create(:user, :with_two_factor) }

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when user is authenticated with 2FA enabled" do
      it "returns http success" do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context "when user has not enabled 2FA" do
      let(:user) { create(:user) }

      it "redirects to setup page" do
        get :show
        expect(response).to redirect_to(two_factor_setup_path)
        expect(flash[:alert]).to include("set up two-factor authentication first")
      end
    end

    context "when user is not authenticated" do
      before do
        sign_out user
      end

      it "redirects to sign in page" do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #verify" do
    let(:user) { create(:user, :with_two_factor) }
    let(:totp) { ROTP::TOTP.new(user.otp_secret) }

    context "with a valid code" do
      it "verifies two-factor authentication" do
        code = totp.now
        post :verify, params: { code: code }
        user.reload
        expect(user.two_factor_verified).to be true
      end

      it "redirects to root path with success message" do
        code = totp.now
        post :verify, params: { code: code }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("verified successfully")
      end
    end

    context "with an invalid code" do
      it "does not verify two-factor authentication" do
        post :verify, params: { code: "000000" }
        user.reload
        expect(user.two_factor_verified).to be false
      end

      it "renders show template with error message" do
        post :verify, params: { code: "000000" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:show)
        expect(flash[:alert]).to include("Invalid code")
      end
    end

    context "with no code" do
      it "does not verify two-factor authentication" do
        post :verify, params: { code: nil }
        user.reload
        expect(user.two_factor_verified).to be false
      end
    end
  end
end
