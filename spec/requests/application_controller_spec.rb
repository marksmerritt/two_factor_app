require 'rails_helper'

RSpec.describe "Application Controller 2FA Protection", type: :request do
  describe "2FA verification requirement" do
    context "when user has 2FA required, enabled but not verified" do
      let(:user) { create(:user, :with_two_factor, :requires_two_factor) }

      before do
        sign_in user
      end

      it "redirects to verification page when accessing home" do
        get root_path
        expect(response).to redirect_to(two_factor_verification_path)
        expect(flash[:alert]).to include("verify your two-factor authentication")
      end

      it "allows access to 2FA setup page" do
        get two_factor_setup_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to 2FA verification page" do
        get two_factor_verification_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user has 2FA required, enabled and verified" do
      let(:user) { create(:user, :with_two_factor_verified, :requires_two_factor) }

      before do
        sign_in user
      end

      it "allows access to home page" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user has 2FA required but not enabled" do
      let(:user) { create(:user, :requires_two_factor) }

      before do
        sign_in user
      end

      it "redirects to setup page when accessing home" do
        get root_path
        expect(response).to redirect_to(two_factor_setup_path)
      end
    end

    context "when user does not have 2FA required" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "allows access to home page without 2FA" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user has 2FA enabled but not required" do
      let(:user) { create(:user, :with_two_factor) }

      before do
        sign_in user
      end

      it "allows access to home page" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

