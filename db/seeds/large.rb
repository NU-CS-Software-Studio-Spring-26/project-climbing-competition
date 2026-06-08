# frozen_string_literal: true

# Development-only bulk seed (~1000 users & competitions).
# Run: bin/rails db:seed:large

require Rails.root.join("db/seeds/support")

USER_COUNT = 1_000
COMPETITION_COUNT = 1_000
BATCH_SIZE = 250

srand(42)

puts "Clearing existing data..."
Attempt.destroy_all
Enrollment.destroy_all
Climb.destroy_all
Competition.destroy_all
Session.destroy_all
User.destroy_all

now = Time.current
password_digest = BCrypt::Password.create(SeedSupport::SEED_PASSWORD)
used_usernames = Set.new
used_emails = Set.new
used_competition_names = Set.new

puts "Building #{USER_COUNT} users..."
user_records = []
USER_COUNT.times do
  attrs = SeedSupport.generate_user_attributes(used_usernames: used_usernames, used_emails: used_emails)
  user_records << attrs.merge(
    password_digest: password_digest,
    created_at: now,
    updated_at: now
  )
end

user_ids = []
user_records.each_slice(BATCH_SIZE).with_index do |batch, index|
  inserted = User.insert_all!(batch, returning: %w[id])
  user_ids.concat(inserted.rows.flatten)
  puts "  Inserted users batch #{index + 1} (#{user_ids.length}/#{USER_COUNT})"
end

first_user = User.find(user_ids.first)
puts "Created #{user_ids.length} users"

puts "Building #{COMPETITION_COUNT} competitions..."
competition_records = []
COMPETITION_COUNT.times do |index|
  level = Competition::LEVELS[index % Competition::LEVELS.length]
  min_grade, max_grade = Competition::LEVEL_GRADE_RANGES.fetch(level)
  starts_at, ends_at = SeedSupport.competition_window(index, total: COMPETITION_COUNT)
  year = starts_at.year

  competition_records << {
    name: SeedSupport.generate_competition_name(level: level, year: year, used_names: used_competition_names),
    level: level,
    starts_at: starts_at,
    ends_at: ends_at,
    description: SeedSupport.generate_competition_description(level),
    owner_id: user_ids.sample,
    send_points: 100,
    flash_points: 125,
    attempt_deduction: 10,
    v_grade_min: min_grade,
    v_grade_max: max_grade,
    created_at: now,
    updated_at: now
  }
end

competition_ids = []
competition_levels = []
competition_records.each_slice(BATCH_SIZE).with_index do |batch, index|
  competition_levels.concat(batch.pluck(:level))
  inserted = Competition.insert_all!(batch, returning: %w[id])
  competition_ids.concat(inserted.rows.flatten)
  puts "  Inserted competitions batch #{index + 1} (#{competition_ids.length}/#{COMPETITION_COUNT})"
end

puts "Building climbs (#{competition_ids.length * 2} rows)..."
climb_records = []
competition_ids.each_with_index do |competition_id, index|
  level = competition_levels[index]
  names = SeedSupport.sample_climb_names(count: 2)
  grades = SeedSupport.grades_for_level(level, count: 2)

  names.each_with_index do |name, idx|
    climb_records << {
      competition_id: competition_id,
      name: name,
      url: SeedSupport::SEED_CLIMB_URL,
      grading: grades[idx],
      created_at: now,
      updated_at: now
    }
  end
end

climb_records.each_slice(BATCH_SIZE).with_index do |batch, index|
  Climb.insert_all!(batch)
  puts "  Inserted climbs batch #{index + 1}" if ((index + 1) * BATCH_SIZE) % 500 == 0 || batch.size < BATCH_SIZE
end
puts "Created #{climb_records.length} climbs"

puts "Building enrollments..."
enrollment_records = []
seen_enrollments = Set.new

competition_ids.each do |competition_id|
  rand(0..10).times do
    user_id = user_ids.sample
    key = [ user_id, competition_id ]
    next if seen_enrollments.include?(key)

    seen_enrollments << key
    enrollment_records << {
      user_id: user_id,
      competition_id: competition_id,
      created_at: now,
      updated_at: now
    }
  end
end

enrollment_records.each_slice(BATCH_SIZE).with_index do |batch, index|
  Enrollment.insert_all!(batch)
  puts "  Inserted enrollments batch #{index + 1}" if index.zero? || batch.size < BATCH_SIZE
end
puts "Created #{enrollment_records.length} enrollments"

puts "\nLarge seed complete!"
puts "  Users: #{User.count}"
puts "  Competitions: #{Competition.count}"
puts "  Climbs: #{Climb.count}"
puts "  Enrollments: #{Enrollment.count}"
puts "\nSample login:"
puts "  Email: #{first_user.email_address} | Password: #{SeedSupport::SEED_PASSWORD}"
