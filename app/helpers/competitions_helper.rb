module CompetitionsHelper
  def competition_time_field_value(datetime)
    datetime&.strftime("%H:%M") || Competition::DEFAULT_TIME
  end

  def v_grade_label(grade)
    grade >= 10 ? "V10+" : "V#{grade}"
  end

  def climb_grade_options(locked_grade_min: nil, locked_grade_max: nil)
    grades = Climb::GRADES

    if locked_grade_min.present? && locked_grade_max.present?
      grades = grades.select do |grading|
        value = grading.to_s.delete_prefix("V").to_i
        value.between?(locked_grade_min.to_i, locked_grade_max.to_i)
      end
    end

    grades
  end

  def next_sort_params(column)
    base = @filter_params.except(:sort_by, :sort_direction)

    if @sort_by != column
      base.merge(sort_by: column, sort_direction: "asc")
    elsif @sort_direction == "asc"
      base.merge(sort_by: column, sort_direction: "desc")
    else
      base
    end
  end
end
