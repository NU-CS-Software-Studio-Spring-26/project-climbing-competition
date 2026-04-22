class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :competition, null: false, foreign_key: true

      t.timestamps
    end

    add_index :enrollments, [ :user_id, :competition_id ], unique: true
  end
end
