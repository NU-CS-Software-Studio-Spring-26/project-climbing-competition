module ApplicationHelper
  def competition_datetime_display(time)
    return "" unless time

    day = time.day
    suffix = if (11..13).cover?(day % 100)
      "th"
    else
      case day % 10
      when 1 then "st"
      when 2 then "nd"
      when 3 then "rd"
      else "th"
      end
    end

    "#{time.strftime('%B')} #{day}#{suffix} #{time.strftime('%-I:%M %p')}"
  end

  def competition_level_label(competition)
    competition.level&.titleize || competition.climb_grade_range_label || "—"
  end

  # Returns a CSS modifier class for a V-grade string (e.g. "V7" -> "grade--moderate").
  def grade_css_class(grading)
    return nil if grading.blank?

    n = grading.delete_prefix("V").to_i
    case n
    when 0..4  then "grade--easy"
    when 5..8  then "grade--moderate"
    when 9..12 then "grade--hard"
    else            "grade--extreme"
    end
  end
end
