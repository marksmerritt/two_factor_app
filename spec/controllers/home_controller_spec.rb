require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    context "when user is authenticated" do
      context "without 2FA enabled" do
        let(:user) { create(:user) }

        before do
          sign_in user
        end

        it "redirects to 2FA setup" do
          get :index
          expect(response).to redirect_to(two_factor_setup_path)
          expect(flash[:notice]).to include("set up two-factor authentication")
        end
      end

      context "with 2FA enabled and verified" do
        let(:user) { create(:user, :with_two_factor_verified) }

        before do
          sign_in user
        end

        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context "with 2FA enabled but not verified" do
        let(:user) { create(:user, :with_two_factor) }

        before do
          sign_in user
        end

        it "redirects to 2FA verification" do
          get :index
          expect(response).to redirect_to(two_factor_verification_path)
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

