# RSpec Test Suite Documentation

This document describes the complete RSpec test suite for the Two-Factor Authentication Rails application.

## Test Coverage

### Model Specs (`spec/models/`)

#### User Model (`user_spec.rb`)
- **Associations and Validations**: Tests email presence and uniqueness
- **`#generate_otp_secret`**: Tests OTP secret generation and persistence
- **`#provisioning_uri`**: Tests QR code URI generation with proper encoding
- **`#verify_totp`**: Comprehensive tests for TOTP code verification including:
  - Valid codes
  - Invalid codes
  - Edge cases (nil, empty string, missing secret)
  - Drift window handling
- **`#two_factor_required?`**: Tests 2FA requirement logic for different states

### Controller Specs (`spec/controllers/`)

#### TwoFactorSetupController (`two_factor_setup_controller_spec.rb`)
- **GET #show**: Tests QR code generation and display
- **POST #enable**: Tests 2FA enabling with valid/invalid codes
- Authentication requirements

#### TwoFactorVerificationController (`two_factor_verification_controller_spec.rb`)
- **GET #show**: Tests verification page access
- **POST #verify**: Tests code verification process
- Redirects for users without 2FA enabled

#### HomeController (`home_controller_spec.rb`)
- **GET #index**: Tests redirects based on 2FA status
- Different scenarios for authenticated/unauthenticated users

### Request Specs (`spec/requests/`)

#### Two Factor Setup (`two_factor_setup_spec.rb`)
- Full request/response cycle for 2FA setup
- QR code display
- Code validation

#### Two Factor Verification (`two_factor_verification_spec.rb`)
- Verification flow
- Access control

#### Application Controller Protection (`application_controller_spec.rb`)
- Tests 2FA requirement enforcement
- Route protection
- Redirect logic

#### Authentication (`authentication_spec.rb`)
- User registration
- Sign in/sign out
- 2FA status reset on login

#### Complete 2FA Flow (`two_factor_flow_spec.rb`)
- **New user flow**: Complete journey from signup to 2FA setup
- **Returning user flow**: Login to verification
- **Invalid code handling**: Error scenarios

## Test Statistics

- **Total Examples**: 75
- **All Passing**: ✅
- **Coverage**: Models, Controllers, Requests, Integration flows

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test
bundle exec rspec spec/models/user_spec.rb:35
```

## Test Dependencies

- **rspec-rails**: RSpec framework for Rails
- **factory_bot_rails**: Test data factories
- **shoulda-matchers**: Model validation matchers
- **database_cleaner-active_record**: Database cleanup between tests
- **faker**: Random test data generation
- **rails-controller-testing**: Controller testing helpers

## Test Configuration

- **Database Cleaner**: Configured to clean database between tests
- **Devise Helpers**: Included for authentication testing
- **FactoryBot**: Configured for easy test data creation
- **Shoulda Matchers**: Configured for model validation tests

## Key Test Scenarios Covered

1. ✅ User model 2FA methods (generate, verify, provisioning)
2. ✅ 2FA setup flow with QR code generation
3. ✅ 2FA verification after login
4. ✅ Route protection requiring 2FA
5. ✅ User registration and authentication
6. ✅ Complete end-to-end 2FA flows
7. ✅ Error handling for invalid codes
8. ✅ Edge cases (nil values, missing secrets, etc.)

## Factory Definitions

The test suite includes a User factory with traits:
- `:with_two_factor`: User with 2FA enabled but not verified
- `:with_two_factor_verified`: User with 2FA enabled and verified

## Notes

- All tests use transactional database cleaning for speed
- Tests are isolated and can run in any order
- FactoryBot provides consistent test data
- ROTP library behavior is properly mocked and tested

