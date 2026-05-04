class AddGradingToClimbs < ActiveRecord::Migration[8.1]
  def change
    add_column :climbs, :grading, :string
  end
end
