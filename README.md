# Two-Factor Authentication Rails App

A Ruby on Rails 7 application with PostgreSQL database, Devise authentication, and custom two-factor authentication (2FA) implementation using TOTP (Time-based One-Time Password).

## Features

- User authentication with Devise
- Two-factor authentication using TOTP
- QR code generation for easy setup with authenticator apps
- Secure verification flow that requires 2FA before accessing the app

## Prerequisites

- Ruby 3.2.2 or higher
- PostgreSQL (running locally or accessible)
- Bundler gem

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Set up the database:**
   Make sure PostgreSQL is running, then:
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Start the Rails server:**
   ```bash
   rails server
   ```

4. **Access the application:**
   Open your browser and navigate to `http://localhost:3000`

## Usage

### First Time Setup

1. **Register a new account:**
   - Navigate to the sign-up page
   - Create a new user account

2. **Set up Two-Factor Authentication:**
   - After signing in, you'll be redirected to the 2FA setup page
   - Scan the QR code with an authenticator app (Google Authenticator, Authy, Microsoft Authenticator, etc.)
   - Enter the 6-digit code from your authenticator app to enable 2FA

3. **Access the application:**
   - Once 2FA is enabled and verified, you can access the main application

### Subsequent Logins

1. **Sign in with your credentials**
2. **Verify with 2FA:**
   - Enter the 6-digit code from your authenticator app
   - Once verified, you'll have access to the application

## How It Works

- **2FA Setup:** Users generate a unique OTP secret and scan a QR code to add it to their authenticator app
- **2FA Verification:** After login, users must verify their identity with a TOTP code before accessing protected routes
- **Session Security:** The 2FA verification status is reset on each login, requiring fresh verification

## Gems Used

- `devise` - Authentication
- `rotp` - TOTP generation and verification
- `rqrcode` - QR code generation

## Routes

- `/` - Home page (requires authentication and 2FA verification)
- `/users/sign_in` - Sign in page
- `/users/sign_up` - Sign up page
- `/two_factor_setup` - 2FA setup page (QR code)
- `/two_factor_verification` - 2FA verification page

## Notes

- The application requires 2FA to be enabled and verified before accessing most routes
- Users are automatically redirected to 2FA setup if they haven't enabled it yet
- Users are redirected to 2FA verification after login if 2FA is enabled
