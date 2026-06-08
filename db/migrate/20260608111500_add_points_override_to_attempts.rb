class AddPointsOverrideToAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :attempts, :points_override, :integer
    add_check_constraint :attempts, "points_override IS NULL OR points_override >= 0", name: "attempt_points_override_non_negative"
  end
end
