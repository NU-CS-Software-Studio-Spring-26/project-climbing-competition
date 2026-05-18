class AddNullConstraintsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :name, false
    change_column_null :users, :username, false
    change_column_null :users, :email_address, false
    change_column_null :users, :password_digest, false
  end
end
