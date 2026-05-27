class AddVGradesToCompetitions < ActiveRecord::Migration[8.1]
  def up
    add_column :competitions, :v_grade_min, :integer
    add_column :competitions, :v_grade_max, :integer

    # Back-fill from the existing level column using raw SQL
    execute <<~SQL
      UPDATE competitions SET
        v_grade_min = CASE level
          WHEN 'beginner'     THEN 0
          WHEN 'intermediate' THEN 4
          WHEN 'advanced'     THEN 7
          WHEN 'elite'        THEN 10
          ELSE 0
        END,
        v_grade_max = CASE level
          WHEN 'beginner'     THEN 3
          WHEN 'intermediate' THEN 6
          WHEN 'advanced'     THEN 9
          WHEN 'elite'        THEN 16
          ELSE 16
        END
    SQL

    change_column_null :competitions, :v_grade_min, false
    change_column_null :competitions, :v_grade_max, false

    add_check_constraint :competitions,
      "v_grade_min >= 0 AND v_grade_min <= 16",
      name: "v_grade_min_range"
    add_check_constraint :competitions,
      "v_grade_max >= 0 AND v_grade_max <= 16",
      name: "v_grade_max_range"
    add_check_constraint :competitions,
      "v_grade_max >= v_grade_min",
      name: "v_grade_max_gte_min"
  end

  def down
    remove_check_constraint :competitions, name: "v_grade_max_gte_min"
    remove_check_constraint :competitions, name: "v_grade_max_range"
    remove_check_constraint :competitions, name: "v_grade_min_range"

    remove_column :competitions, :v_grade_min
    remove_column :competitions, :v_grade_max
  end
end
