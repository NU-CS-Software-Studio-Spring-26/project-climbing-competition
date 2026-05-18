# frozen_string_literal: true

# Default seed data for development, test, and CI (db:seed / db:seed:replant).
# For ~1000 users and competitions in development only, run: bin/rails db:seed:large

require Rails.root.join("db/seeds/support")

Attempt.destroy_all
Enrollment.destroy_all
Climb.destroy_all
Competition.destroy_all
Session.destroy_all
User.destroy_all

users_data = [
  { name: "Alex Rivera", username: "alexrivera", email_address: "alex@climbing.local", bio: "V-grader and spray beta enthusiast" },
  { name: "Jordan Chen", username: "jordanclimbs", email_address: "jordan@climbing.local", bio: "Boulderer from the Bay Area" },
  { name: "Morgan Lee", username: "morganflash", email_address: "morgan@climbing.local", bio: "Speed climber | Competition junkie" },
  { name: "Casey Thompson", username: "caseyboulds", email_address: "casey@climbing.local", bio: "Outdoor crag rat, indoor gym lover" },
  { name: "Parker Davis", username: "parkersends", email_address: "parker@climbing.local", bio: "Route setter by day, climber by night" }
]

users = users_data.map do |data|
  User.create!(data.merge(password: SeedSupport::SEED_PASSWORD))
end

puts "Created #{users.length} users"

competitions_data = [
  {
    name: "Spring Send Fest 2026",
    level: "beginner",
    starts_at: Time.zone.parse("2026-05-15 09:00:00"),
    ends_at: Time.zone.parse("2026-05-15 17:00:00"),
    description: SeedSupport.generate_competition_description("beginner"),
    climbs: [
      { name: "Slopers Warm-up", url: SeedSupport::SEED_CLIMB_URL },
      { name: "Jug Ladder", url: SeedSupport::SEED_CLIMB_URL }
    ]
  },
  {
    name: "Midwest Regional Championship",
    level: "intermediate",
    starts_at: Time.zone.parse("2026-06-02 08:00:00"),
    ends_at: Time.zone.parse("2026-06-02 18:00:00"),
    description: SeedSupport.generate_competition_description("intermediate"),
    climbs: [
      { name: "Crimpy Sequence", url: SeedSupport::SEED_CLIMB_URL },
      { name: "Dyno to Sloper", url: SeedSupport::SEED_CLIMB_URL }
    ]
  },
  {
    name: "Elite Nationals Qualifier",
    level: "elite",
    starts_at: Time.zone.parse("2026-07-20 10:00:00"),
    ends_at: Time.zone.parse("2026-07-20 20:00:00"),
    description: SeedSupport.generate_competition_description("elite"),
    climbs: [
      { name: "One-Finger Pocket Nightmare", url: SeedSupport::SEED_CLIMB_URL },
      { name: "Volume to Dyno Sprint", url: SeedSupport::SEED_CLIMB_URL }
    ]
  },
  {
    name: "Summer Boulder Bash",
    level: "beginner",
    starts_at: Time.zone.parse("2026-06-10 09:00:00"),
    ends_at: Time.zone.parse("2026-06-10 16:00:00"),
    description: SeedSupport.generate_competition_description("beginner"),
    climbs: [
      { name: "Warm-up Jugs", url: SeedSupport::SEED_CLIMB_URL },
      { name: "Easy Slopers", url: SeedSupport::SEED_CLIMB_URL }
    ]
  },
  {
    name: "Advanced Youth Open",
    level: "advanced",
    starts_at: Time.zone.parse("2026-05-28 10:00:00"),
    ends_at: Time.zone.parse("2026-05-28 17:00:00"),
    description: SeedSupport.generate_competition_description("advanced"),
    climbs: [
      { name: "Tiny Edges Test", url: SeedSupport::SEED_CLIMB_URL },
      { name: "Compression Master", url: SeedSupport::SEED_CLIMB_URL }
    ]
  }
]

competitions = competitions_data.map do |data|
  climbs = data.delete(:climbs)
  climbs_attributes = climbs.each_with_index.to_h { |climb, index| [ index.to_s, climb ] }

  comp = users.sample.owned_competitions.create!(
    data.merge(
      climbs_attributes: climbs_attributes,
      send_points: 100,
      flash_points: 125,
      attempt_deduction: 10
    )
  )
  grades = SeedSupport.grades_for_level(comp.level, count: comp.climbs.count)
  comp.climbs.each_with_index { |climb, idx| climb.update!(grading: grades[idx]) }
  comp
end

puts "Created #{competitions.count} competitions with climbs"

competitions.each do |comp|
  users.sample(rand(2..4)).each do |user|
    Enrollment.find_or_create_by!(user: user, competition: comp)
  end
end

puts "Created enrollments"
puts "\nSeed data complete!"
puts "Sample login: alex@climbing.local | Password: #{SeedSupport::SEED_PASSWORD}"
