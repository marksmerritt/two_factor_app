require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "User registration" do
    it "allows user to sign up" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
    end

    it "creates a new user" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change(User, :count).by(1)
    end

    it "redirects after successful registration" do
      post user_registration_path, params: {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "User sign in" do
    let(:user) { create(:user, password: "password123") }

    it "allows user to sign in" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end

    it "signs in user with correct credentials" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }
      expect(response).to redirect_to(root_path)
    end

    it "does not sign in with incorrect password" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "wrongpassword"
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "with 2FA enabled" do
      let(:user) { create(:user, :with_two_factor, password: "password123") }

      it "resets 2FA verification status on login" do
        user.update(two_factor_verified: true)
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "password123"
          }
        }
        user.reload
        expect(user.two_factor_verified).to be false
      end
    end
  end

  describe "User sign out" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "signs out the user" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end

