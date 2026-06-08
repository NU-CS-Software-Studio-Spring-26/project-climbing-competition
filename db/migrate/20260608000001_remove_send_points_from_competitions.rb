class RemoveSendPointsFromCompetitions < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :competitions, name: "send_points_range"
    remove_column :competitions, :send_points, :integer
  end
end
