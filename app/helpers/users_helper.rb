module UsersHelper
  def link_to_user_profile(user, label: nil, class_name: "profile-user-link", stop_row_toggle: false)
    return tag.span(label || "—", class: class_name) if user.blank?

    label ||= user.name
    options = { class: class_name }
    options[:onclick] = "event.stopPropagation()" if stop_row_toggle

    link_to label, user_path(user), **options
  end

  def format_average_placement(value)
    return "—" if value.nil?

    value == value.to_i ? value.to_i.to_s : value.to_s
  end

  def placement_label(rank)
    return nil if rank.blank?

    rank.ordinalize
  end
end
