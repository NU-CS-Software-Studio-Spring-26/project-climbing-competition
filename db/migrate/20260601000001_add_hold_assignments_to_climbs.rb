class AddHoldAssignmentsToClimbs < ActiveRecord::Migration[8.1]
  def change
    add_column :climbs, :hold_assignments, :json, null: false, default: {}
  end
end