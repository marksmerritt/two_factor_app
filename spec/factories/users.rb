FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    two_factor_auth_required { false }
    
    trait :with_two_factor do
      otp_secret { ROTP::Base32.random }
      two_factor_enabled { true }
      two_factor_verified { false }
    end
    
    trait :with_two_factor_verified do
      otp_secret { ROTP::Base32.random }
      two_factor_enabled { true }
      two_factor_verified { true }
    end
    
    trait :requires_two_factor do
      two_factor_auth_required { true }
    end
  end
end

