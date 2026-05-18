class ChangeDefaultScoringSettingsOnCompetitions < ActiveRecord::Migration[7.1]
  def change
    change_column_default :competitions, :send_points,       from: 100, to: 25
    change_column_default :competitions, :flash_points,      from: 125, to: 30
    change_column_default :competitions, :attempt_deduction, from: 10,  to: 5
  end
end
