module ApplicationHelper
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
