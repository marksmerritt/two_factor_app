class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      # Reset 2FA verification status on each login
      if resource.two_factor_enabled?
        resource.update(two_factor_verified: false)
      end
    end
  end
end

