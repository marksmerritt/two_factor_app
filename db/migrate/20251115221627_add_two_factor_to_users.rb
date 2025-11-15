class AddTwoFactorToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :two_factor_enabled, :boolean, default: false
    add_column :users, :two_factor_verified, :boolean, default: false
  end
end
