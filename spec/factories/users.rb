FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    
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
  end
end

