require 'rails_helper'

RSpec.describe TwoFactorSetupController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when user is authenticated" do
      it "returns http success" do
        get :show
        expect(response).to have_http_status(:success)
      end

      it "generates an OTP secret if user doesn't have one" do
        expect(user.otp_secret).to be_nil
        get :show
        user.reload
        expect(user.otp_secret).not_to be_nil
      end

      it "does not regenerate secret if user already has one" do
        user.update(otp_secret: "EXISTING_SECRET")
        get :show
        user.reload
        expect(user.otp_secret).to eq("EXISTING_SECRET")
      end

      it "assigns @qr_code_svg" do
        get :show
        expect(assigns(:qr_code_svg)).not_to be_nil
        expect(assigns(:qr_code_svg)).to include("svg")
      end

      it "generates a valid QR code SVG" do
        get :show
        qr_svg = assigns(:qr_code_svg)
        expect(qr_svg).to include("<svg")
        expect(qr_svg).to include("</svg>")
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

  describe "POST #enable" do
    let(:user) { create(:user, otp_secret: ROTP::Base32.random) }
    let(:totp) { ROTP::TOTP.new(user.otp_secret) }

    context "with a valid code" do
      it "enables two-factor authentication" do
        code = totp.now
        post :enable, params: { code: code }
        user.reload
        expect(user.two_factor_enabled).to be true
        expect(user.two_factor_verified).to be true
      end

      it "redirects to root path with success message" do
        code = totp.now
        post :enable, params: { code: code }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("enabled successfully")
      end
    end

    context "with an invalid code" do
      it "does not enable two-factor authentication" do
        post :enable, params: { code: "000000" }
        user.reload
        expect(user.two_factor_enabled).to be false
      end

      it "redirects back to setup page with error message" do
        post :enable, params: { code: "000000" }
        expect(response).to redirect_to(two_factor_setup_path)
        expect(flash[:alert]).to include("Invalid code")
      end
    end

    context "with no code" do
      it "does not enable two-factor authentication" do
        post :enable, params: { code: nil }
        user.reload
        expect(user.two_factor_enabled).to be false
      end
    end
  end
end

