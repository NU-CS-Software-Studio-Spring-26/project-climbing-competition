module CompetitionsHelper
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
