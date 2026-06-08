class SimplifyAttemptReviewToInvalidatedFlag < ActiveRecord::Migration[8.1]
  def up
    add_column :attempts, :invalidated, :boolean, null: false, default: false

    execute <<~SQL
      UPDATE attempts
      SET invalidated = TRUE
      WHERE review_status = 2
    SQL

    remove_check_constraint :attempts, name: "attempt_review_status_range"
    remove_check_constraint :attempts, name: "attempt_points_override_non_negative"

    remove_column :attempts, :review_status, :integer
    remove_column :attempts, :points_override, :integer
  end

  def down
    add_column :attempts, :review_status, :integer, null: false, default: 0
    add_column :attempts, :points_override, :integer

    add_check_constraint :attempts, "review_status IN (0, 1, 2)", name: "attempt_review_status_range"
    add_check_constraint :attempts, "points_override IS NULL OR points_override >= 0", name: "attempt_points_override_non_negative"

    execute <<~SQL
      UPDATE attempts
      SET review_status = 2
      WHERE invalidated = TRUE
    SQL

    remove_column :attempts, :invalidated, :boolean
  end
end
