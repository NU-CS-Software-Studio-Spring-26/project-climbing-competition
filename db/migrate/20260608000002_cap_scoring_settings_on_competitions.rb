class CapScoringSettingsOnCompetitions < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE competitions
      SET flash_points = MIN(flash_points, 50),
          attempt_deduction = MIN(attempt_deduction, 10)
    SQL

    remove_check_constraint :competitions, name: "flash_points_range"
    remove_check_constraint :competitions, name: "attempt_deduction_range"

    add_check_constraint :competitions,
      "flash_points > 0 AND flash_points <= 50",
      name: "flash_points_range"
    add_check_constraint :competitions,
      "attempt_deduction >= 0 AND attempt_deduction <= 10",
      name: "attempt_deduction_range"
  end

  def down
    remove_check_constraint :competitions, name: "attempt_deduction_range"
    remove_check_constraint :competitions, name: "flash_points_range"

    add_check_constraint :competitions,
      "flash_points > 0 AND flash_points <= 10000",
      name: "flash_points_range"
    add_check_constraint :competitions,
      "attempt_deduction >= 0 AND attempt_deduction <= 10000",
      name: "attempt_deduction_range"
  end
end
