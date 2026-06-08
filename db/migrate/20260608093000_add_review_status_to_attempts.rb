class AddReviewStatusToAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :attempts, :review_status, :integer, null: false, default: 0
    add_check_constraint :attempts, "review_status IN (0, 1, 2)", name: "attempt_review_status_range"
  end
end
