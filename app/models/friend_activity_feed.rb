class FriendActivityFeed
  Activity = Struct.new(
    :kind,
    :user,
    :occurred_at,
    :competition,
    :climb,
    :attempt,
    :placement,
    keyword_init: true
  )

  LOOKBACK = 90.days
  DEFAULT_LIMIT = 15

  def self.for(user, limit: DEFAULT_LIMIT)
    new(user, limit: limit).activities
  end

  def initialize(user, limit: DEFAULT_LIMIT)
    @user = user
    @limit = limit
    @since = LOOKBACK.ago
    @friend_ids = user.following.pluck(:id)
  end

  def activities
    return [] if @friend_ids.empty?

    items = enrollment_activities + attempt_activities + placement_activities
    items.sort_by!(&:occurred_at)
    items.reverse!
    items.first(@limit)
  end

  private

  def enrollment_activities
    Enrollment
      .where(user_id: @friend_ids)
      .where("created_at >= ?", @since)
      .includes(:user, :competition)
      .order(created_at: :desc)
      .map do |enrollment|
        Activity.new(
          kind: :joined,
          user: enrollment.user,
          occurred_at: enrollment.created_at,
          competition: enrollment.competition
        )
      end
  end

  def attempt_activities
    Attempt
      .where(user_id: @friend_ids)
      .where("updated_at >= ?", @since)
      .includes(:user, climb: :competition)
      .order(updated_at: :desc)
      .map do |attempt|
        Activity.new(
          kind: :attempt,
          user: attempt.user,
          occurred_at: attempt.updated_at,
          competition: attempt.competition,
          climb: attempt.climb,
          attempt: attempt
        )
      end
  end

  def placement_activities
    Competition
      .past
      .where("ends_at >= ?", @since)
      .joins(:enrollments)
      .where(enrollments: { user_id: @friend_ids })
      .distinct
      .includes(:enrollments)
      .flat_map do |competition|
        competition.leaderboard_entries.filter_map do |entry|
          next unless @friend_ids.include?(entry.user.id)

          placement = competition.placement_for(entry.user)
          next if placement.blank?

          Activity.new(
            kind: :placed,
            user: entry.user,
            occurred_at: competition.ends_at,
            competition: competition,
            placement: placement
          )
        end
      end
  end
end
