# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here is idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Re-seeding updates existing rows matched by username (users) or competition name (competitions). It does not delete
# stale records; use db:reset for a clean slate.

LOREM = <<~TEXT.strip.freeze
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
TEXT

USER_SEEDS = [
  { name: "Eric Wang", username: "eric_wang" },
  { name: "Ethan Pan", username: "ethan_pan" },
  { name: "Ishani Pidara", username: "ish_climbs" },
  { name: "Hannah Kwak", username: "hannah_k" },
  { name: "Jordan Reyes", username: "crimp_lord" },
  { name: "Sam Okonkwo", username: "slab_whisperer" },
  { name: "Alex Kim", username: "dyno_dan" },
  { name: "Riley Chen", username: "board_rat_99" },
  { name: "Morgan Blake", username: "kilter_moose" },
  { name: "Casey Nguyen", username: "tension_taylor" },
  { name: "Jamie Foster", username: "campus_kid" },
  { name: "Taylor Brooks", username: "rest_day_rachel" }
].freeze

# start_offset: days from Date.current; duration_days: length of window (end = start + duration)
COMPETITION_SEEDS = [
  { name: "Spring Kilter League", description: LOREM, start_offset: 7, duration_days: 5, difficulty: 8, owner_username: "eric_wang" },
  { name: "Tension Board After Dark", description: LOREM, start_offset: 14, duration_days: 3, difficulty: 10, owner_username: "ethan_pan" },
  { name: "NU Bouldering Social", description: LOREM, start_offset: -7, duration_days: 1, difficulty: 4, owner_username: "ish_climbs" },
  { name: "Campus Board Power Hour", description: LOREM, start_offset: 3, duration_days: 0, difficulty: 12, owner_username: "hannah_k" },
  { name: "Midwest Sendfest Qualifier", description: LOREM, start_offset: -21, duration_days: 6, difficulty: 9, owner_username: "crimp_lord" },
  { name: "Late Night V-Five Jam", description: LOREM, start_offset: 21, duration_days: 2, difficulty: 5, owner_username: "slab_whisperer" },
  { name: "Gym Rats Mini Comp", description: LOREM, start_offset: -30, duration_days: 4, difficulty: 6, owner_username: "dyno_dan" },
  { name: "Virtual Board Battle", description: LOREM, start_offset: 35, duration_days: 7, difficulty: 11, owner_username: "board_rat_99" },
  { name: "Community Open Night", description: LOREM, start_offset: 0, duration_days: 2, difficulty: 3, owner_username: nil },
  { name: "Friday Flash League", description: LOREM, start_offset: -14, duration_days: 1, difficulty: 7, owner_username: "kilter_moose" }
].freeze

# Deterministic enrollments (user must exist; competition name must match COMPETITION_SEEDS)
ENROLLMENT_SEEDS = [
  { username: "ethan_pan", competition_name: "Spring Kilter League" },
  { username: "ish_climbs", competition_name: "Spring Kilter League" },
  { username: "hannah_k", competition_name: "Spring Kilter League" },
  { username: "eric_wang", competition_name: "Tension Board After Dark" },
  { username: "campus_kid", competition_name: "NU Bouldering Social" },
  { username: "rest_day_rachel", competition_name: "Virtual Board Battle" },
  { username: "tension_taylor", competition_name: "Friday Flash League" }
].freeze

USER_SEEDS.each do |attrs|
  user = User.find_or_initialize_by(username: attrs[:username])
  user.name = attrs[:name]
  user.save!
end

users_by_username = User.all.index_by(&:username)

COMPETITION_SEEDS.each do |attrs|
  start_date = Date.current + attrs[:start_offset]
  end_date = start_date + attrs[:duration_days]
  owner = attrs[:owner_username] ? users_by_username[attrs[:owner_username]] : nil

  competition = Competition.find_or_initialize_by(name: attrs[:name])
  competition.assign_attributes(
    description: attrs[:description],
    competition_start: start_date,
    competition_end: end_date,
    difficulty: attrs[:difficulty],
    owner: owner
  )
  competition.save!
end

ENROLLMENT_SEEDS.each do |attrs|
  user = User.find_by(username: attrs[:username])
  competition = Competition.find_by(name: attrs[:competition_name])
  next unless user && competition

  Enrollment.find_or_create_by!(user: user, competition: competition)
end
