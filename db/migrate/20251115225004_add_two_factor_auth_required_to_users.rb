class AddTwoFactorAuthRequiredToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :two_factor_auth_required, :boolean, default: false
  end
end
