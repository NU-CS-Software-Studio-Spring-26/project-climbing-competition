class AddLevelToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :level, :string
  end
end
