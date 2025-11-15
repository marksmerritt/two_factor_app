require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations and validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe "#generate_otp_secret" do
    let(:user) { create(:user) }

    it "generates a new OTP secret" do
      expect(user.otp_secret).to be_nil
      user.generate_otp_secret
      expect(user.otp_secret).not_to be_nil
      expect(user.otp_secret.length).to be > 0
    end

    it "saves the secret to the database" do
      user.generate_otp_secret
      user.reload
      expect(user.otp_secret).not_to be_nil
    end

    it "generates a Base32 encoded secret" do
      user.generate_otp_secret
      # Base32 strings should only contain A-Z and 2-7
      expect(user.otp_secret).to match(/\A[A-Z2-7]+\z/)
    end
  end

  describe "#provisioning_uri" do
    let(:user) { create(:user, otp_secret: ROTP::Base32.random) }

    it "returns a valid provisioning URI" do
      uri = user.provisioning_uri
      expect(uri).to include("otpauth://totp/")
      # Email is URL encoded in the URI
      expect(uri).to include(ERB::Util.url_encode(user.email))
      expect(uri).to include("Two%20Factor%20App")
    end

    it "includes the issuer name" do
      uri = user.provisioning_uri
      expect(uri).to include("issuer=Two%20Factor%20App")
    end

    context "when otp_secret is nil" do
      let(:user) { create(:user, otp_secret: nil) }

      it "returns nil" do
        expect(user.provisioning_uri).to be_nil
      end
    end
  end

  describe "#verify_totp" do
    let(:user) { create(:user, otp_secret: ROTP::Base32.random) }
    let(:totp) { ROTP::TOTP.new(user.otp_secret) }

    context "with a valid code" do
      it "returns true for a current code" do
        code = totp.now
        expect(user.verify_totp(code)).to be true
      end

      it "accepts codes within the drift window" do
        # Get a code from current time (within drift window)
        code = totp.now
        expect(user.verify_totp(code)).to be true
      end
    end

    context "with an invalid code" do
      it "returns false for an incorrect code" do
        expect(user.verify_totp("000000")).to be false
      end

      it "returns false for an expired code" do
        # Get a code from 2 minutes ago (well outside drift window of 15 seconds)
        code = totp.at(Time.now - 120)
        expect(user.verify_totp(code)).to be false
      end

      it "returns false for nil" do
        expect(user.verify_totp(nil)).to be false
      end

      it "returns false for empty string" do
        expect(user.verify_totp("")).to be false
      end
    end

    context "when otp_secret is nil" do
      let(:user) { create(:user, otp_secret: nil) }

      it "returns false" do
        expect(user.verify_totp("123456")).to be false
      end
    end
  end

  describe "#two_factor_required?" do
    context "when 2FA is not enabled" do
      let(:user) { create(:user) }

      it "returns false" do
        expect(user.two_factor_required?).to be false
      end
    end

    context "when 2FA is enabled but not verified" do
      let(:user) { create(:user, :with_two_factor) }

      it "returns true" do
        expect(user.two_factor_required?).to be true
      end
    end

    context "when 2FA is enabled and verified" do
      let(:user) { create(:user, :with_two_factor_verified) }

      it "returns false" do
        expect(user.two_factor_required?).to be false
      end
    end
  end
end
