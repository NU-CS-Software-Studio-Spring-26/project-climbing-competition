class CreateAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :climb, null: false, foreign_key: true
      t.integer :attempt_count, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :attempts, [ :user_id, :climb_id ], unique: true
    add_check_constraint :attempts, "attempt_count >= 1 AND attempt_count <= 100", name: "attempt_count_between_1_and_100"
  end
end
