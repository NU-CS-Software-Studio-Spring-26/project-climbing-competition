class AddAuthAndProfileToUsers < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:users, :email_address)
      add_column :users, :email_address, :string, null: false
    end
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string, null: false
    end
    unless column_exists?(:users, :bio)
      add_column :users, :bio, :text
    end

    return if index_exists?(:users, :email_address)

    add_index :users, :email_address, unique: true
  end

  def down
    remove_index :users, :email_address if index_exists?(:users, :email_address)
    remove_column :users, :bio if column_exists?(:users, :bio)
    remove_column :users, :password_digest if column_exists?(:users, :password_digest)
    remove_column :users, :email_address if column_exists?(:users, :email_address)
  end
end
