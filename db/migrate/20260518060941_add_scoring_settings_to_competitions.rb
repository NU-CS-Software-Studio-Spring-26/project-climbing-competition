class AddScoringSettingsToCompetitions < ActiveRecord::Migration[7.1]
  def change
    add_column :competitions, :send_points,       :integer, default: 100, null: false
    add_column :competitions, :flash_points,      :integer, default: 125, null: false
    add_column :competitions, :attempt_deduction, :integer, default: 10,  null: false
  end
end