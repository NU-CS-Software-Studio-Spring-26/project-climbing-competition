module FriendsHelper
  ACTIVITY_KIND_LABELS = {
    joined: "joined",
    attempt: "climb",
    placed: "placed"
  }.freeze

  def friend_activity_kind_label(activity)
    ACTIVITY_KIND_LABELS.fetch(activity.kind, "Update")
  end

  def friend_activity_body(activity)
    user_link = link_to_user_profile(activity.user, label: activity.user.name, class_name: "profile-user-link")
    action = friend_activity_action(activity)

    safe_join([ user_link, " ", action ])
  end

  def friend_activity_action(activity)
    competition_link = link_to(
      activity.competition.name,
      competition_path(activity.competition),
      class: "friends-activity-link"
    )

    case activity.kind
    when :joined
      safe_join([ "joined ", competition_link ])
    when :attempt
      climb_name = activity.climb.name
      attempt = activity.attempt

      verb = attempt.attempt_count == 1 ? "flashed" : "sent"
      safe_join([ verb, " ", content_tag(:span, climb_name, class: "friends-activity-emphasis"), " in ", competition_link ])
    when :placed
      safe_join([ "placed ", placement_label(activity.placement), " in ", competition_link ])
    else
      ""
    end
  end

  def friend_activity_timestamp(activity)
    time_ago_in_words(activity.occurred_at) + " ago"
  end
end
