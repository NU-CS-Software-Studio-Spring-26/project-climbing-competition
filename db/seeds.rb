# frozen_string_literal: true

# Default seed data for development, test, and CI (db:seed / db:seed:replant).
# For ~1000 users and competitions in development only, run: bin/rails db:seed:large

require Rails.root.join("db/seeds/support")

# Temporary until seeds are revamped: shift fixed competition dates forward so enrollments
# stay joinable when running db:seed through 2026-07-15.
SEED_DATE_OFFSET = 75.days

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
  { name: "Parker Davis", username: "parkersends", email_address: "parker@climbing.local", bio: "Route setter by day, climber by night" },
  { name: "Riley Kim", username: "rileybeta", email_address: "riley@climbing.local", bio: "Training for nationals" },
  { name: "Avery Johnson", username: "averyclimbs", email_address: "avery@climbing.local", bio: "Youth competitive climber" },
  { name: "Taylor Brown", username: "taylorboulder", email_address: "taylor@climbing.local", bio: "Problem solver and crimper" }
]

users = users_data.map do |data|
  User.create!(data.merge(password: SeedSupport::SEED_PASSWORD))
end

puts "Created #{users.length} users"

CLIMB_URL = "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6"

# Create competitions with climbs
# v_grade_min/v_grade_max replace the old level string:
#   beginner     => V0–V3
#   intermediate => V4–V6
#   advanced     => V7–V9
#   elite        => V10–V16
competitions_data = [
  {
    name: "Spring Send Fest 2026",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-05-15 09:00:00",
    ends_at: "2026-05-15 17:00:00",
    description: "Open to climbers new to competition. Great atmosphere and plenty of cheering!",
    climb_grades: %w[V2 V3 V3],
    climbs: [
      { name: "Slopers Warm-up", url: CLIMB_URL },
      { name: "Jug Ladder", url: CLIMB_URL },
      { name: "Topout Finish", url: CLIMB_URL }
    ]
  },
  {
    name: "Midwest Regional Championship",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-06-02 08:00:00",
    ends_at: "2026-06-02 18:00:00",
    description: "Qualifying round for nationals. All skill levels welcome.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Crimpy Sequence", url: CLIMB_URL },
      { name: "Dyno to Sloper", url: CLIMB_URL },
      { name: "Compression Cave", url: CLIMB_URL }
    ]
  },
  {
    name: "Elite Nationals Qualifier",
    v_grade_min: 10, v_grade_max: 16,
    starts_at: "2026-07-20 10:00:00",
    ends_at: "2026-07-20 20:00:00",
    description: "Invite-only competition for top climbers. Tough problems and fierce competition.",
    climb_grades: %w[V10 V12 V14],
    climbs: [
      { name: "One-Finger Pocket Nightmare", url: CLIMB_URL },
      { name: "Volume to Dyno Sprint", url: CLIMB_URL },
      { name: "Final Hold Gauntlet", url: CLIMB_URL }
    ]
  },
  {
    name: "Summer Boulder Bash",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-06-10 09:00:00",
    ends_at: "2026-06-10 16:00:00",
    description: "Casual comp with fun prizes. Perfect for your first competition!",
    climb_grades: %w[V0 V1 V3],
    climbs: [
      { name: "Warm-up Jugs", url: CLIMB_URL },
      { name: "Easy Slopers", url: CLIMB_URL },
      { name: "Confidence Builder", url: CLIMB_URL }
    ]
  },
  {
    name: "Advanced Youth Open",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-05-28 10:00:00",
    ends_at: "2026-05-28 17:00:00",
    description: "For climbers aged 13-18 with solid climbing experience.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Tiny Edges Test", url: CLIMB_URL },
      { name: "Compression Master", url: CLIMB_URL },
      { name: "Toe Hook Line", url: CLIMB_URL }
    ]
  },
  {
    name: "Local Gym Championship",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-05-22 18:00:00",
    ends_at: "2026-05-23 00:00:00",
    description: "Friendly competition at our home gym. Food trucks and live music!",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Mid-Grade Crimps", url: CLIMB_URL },
      { name: "Dynamic Jumpers", url: CLIMB_URL },
      { name: "Competition Flows", url: CLIMB_URL }
    ]
  },
  {
    name: "Women's Boulder Invitational",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-06-15 09:00:00",
    ends_at: "2026-06-15 18:00:00",
    description: "Celebrating women in climbing. Amazing prize purse and sponsorships.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Powerful Pockets", url: CLIMB_URL },
      { name: "Endurance Challenge", url: CLIMB_URL },
      { name: "Precision Finale", url: CLIMB_URL }
    ]
  },
  {
    name: "Beginner Basics Series - Round 1",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-05-10 10:00:00",
    ends_at: "2026-05-10 15:00:00",
    description: "Learn comp format and climb with other beginners. No pressure, all fun!",
    climb_grades: %w[V0 V1 V2],
    climbs: [
      { name: "Getting Started", url: CLIMB_URL },
      { name: "Basic Moves", url: CLIMB_URL },
      { name: "Top Rope Practice", url: CLIMB_URL }
    ]
  },
  {
    name: "May Madness Bouldering Series",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-05-31 11:00:00",
    ends_at: "2026-05-31 19:00:00",
    description: "Fast-paced qualifier round with multiple heats throughout the day.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Speed Boulder", url: CLIMB_URL },
      { name: "Power Endurance", url: CLIMB_URL },
      { name: "Final Burn", url: CLIMB_URL }
    ]
  },
  {
    name: "Rising Stars Youth Championship",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-06-05 09:00:00",
    ends_at: "2026-06-05 14:00:00",
    description: "For younger climbers just starting their competition journey.",
    climb_grades: %w[V0 V1 V2],
    climbs: [
      { name: "Youth Jug Haul", url: CLIMB_URL },
      { name: "Kid-Friendly Volume", url: CLIMB_URL },
      { name: "Tiny Topout", url: CLIMB_URL }
    ]
  },
  {
    name: "Technical Tactics Training",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-06-18 15:00:00",
    ends_at: "2026-06-18 22:00:00",
    description: "Focused on technical movement and problem solving. Advanced techniques only.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Precision Required", url: CLIMB_URL },
      { name: "Balance Master", url: CLIMB_URL },
      { name: "Tension Finale", url: CLIMB_URL }
    ]
  },
  {
    name: "Elite Speed Challenge",
    v_grade_min: 10, v_grade_max: 16,
    starts_at: "2026-07-10 14:00:00",
    ends_at: "2026-07-10 18:00:00",
    description: "Timed speed climbing event. Clock is your competitor.",
    climb_grades: %w[V10 V11 V12],
    climbs: [
      { name: "Fast Track", url: CLIMB_URL },
      { name: "Lightning Route", url: CLIMB_URL },
      { name: "Clock Crusher", url: CLIMB_URL }
    ]
  },
  {
    name: "Intermediate Skills Workshop",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-06-20 10:00:00",
    ends_at: "2026-06-20 17:00:00",
    description: "Build your skills and compete with climbers at your level.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Skill Builder A", url: CLIMB_URL },
      { name: "Skill Builder B", url: CLIMB_URL },
      { name: "Movement Clinic", url: CLIMB_URL }
    ]
  },
  {
    name: "Endurance Fest 2026",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-06-25 08:00:00",
    ends_at: "2026-06-25 20:00:00",
    description: "Long format competition testing stamina and mental strength.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Long Haul Alpha", url: CLIMB_URL },
      { name: "Long Haul Beta", url: CLIMB_URL },
      { name: "Stamina Finish", url: CLIMB_URL }
    ]
  },
  {
    name: "Regional Qualifier Series",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-07-05 12:00:00",
    ends_at: "2026-07-05 20:00:00",
    description: "Earn your spot at the nationals through this qualifier event.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Qualifier Problem 1", url: CLIMB_URL },
      { name: "Qualifier Problem 2", url: CLIMB_URL },
      { name: "Qualifier Problem 3", url: CLIMB_URL }
    ]
  },
  {
    name: "Beginner Confidence Boost",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-06-08 10:00:00",
    ends_at: "2026-06-08 15:00:00",
    description: "All about building confidence in a supportive environment.",
    climb_grades: %w[V0 V1 V2],
    climbs: [
      { name: "Confidence Builder", url: CLIMB_URL },
      { name: "Success Guaranteed", url: CLIMB_URL },
      { name: "Happy Send Off", url: CLIMB_URL }
    ]
  },
  {
    name: "Campus Board Kings",
    v_grade_min: 10, v_grade_max: 16,
    starts_at: "2026-07-25 16:00:00",
    ends_at: "2026-07-25 21:00:00",
    description: "Extreme power test on the campus board. Elite climbers only.",
    climb_grades: %w[V10 V12 V14],
    climbs: [
      { name: "Campus Ladder Extreme", url: CLIMB_URL },
      { name: "Power Sprint", url: CLIMB_URL },
      { name: "Elite Finish", url: CLIMB_URL }
    ]
  },
  {
    name: "Dynamics Showcase",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-07-08 11:00:00",
    ends_at: "2026-07-08 18:00:00",
    description: "Test your jumping and dynamic movement skills against the best.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Dyno Gauntlet", url: CLIMB_URL },
      { name: "Air Time Challenge", url: CLIMB_URL },
      { name: "Launch Sequence", url: CLIMB_URL }
    ]
  },
  {
    name: "Pocket Pincher Pro Open",
    v_grade_min: 10, v_grade_max: 16,
    starts_at: "2026-08-01 09:00:00",
    ends_at: "2026-08-01 17:00:00",
    description: "All-pocket format challenge. Crimp strength and technique required.",
    climb_grades: %w[V10 V11 V12],
    climbs: [
      { name: "Pocket Paradise", url: CLIMB_URL },
      { name: "Precision Pockets", url: CLIMB_URL },
      { name: "Pocket Finale", url: CLIMB_URL }
    ]
  },
  {
    name: "Slopers Slammed",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-06-28 14:00:00",
    ends_at: "2026-06-28 21:00:00",
    description: "All sloper format testing balance and technique.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Slope Master", url: CLIMB_URL },
      { name: "Slope Control", url: CLIMB_URL },
      { name: "Angle Shift", url: CLIMB_URL }
    ]
  },
  {
    name: "Volume Vendetta",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-07-12 09:00:00",
    ends_at: "2026-07-12 16:00:00",
    description: "Big volume problems demand big movements. Are you ready?",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Mega Volume", url: CLIMB_URL },
      { name: "Size Matters", url: CLIMB_URL },
      { name: "Volume Finale", url: CLIMB_URL }
    ]
  },
  {
    name: "Beginner Boulder Bash Encore",
    v_grade_min: 0, v_grade_max: 3,
    starts_at: "2026-07-01 10:00:00",
    ends_at: "2026-07-01 15:00:00",
    description: "Popular beginner event is back! Join us again for another round.",
    climb_grades: %w[V1 V2 V3],
    climbs: [
      { name: "Fun Boulder A", url: CLIMB_URL },
      { name: "Fun Boulder B", url: CLIMB_URL },
      { name: "Fun Boulder C", url: CLIMB_URL }
    ]
  },
  {
    name: "Intermediate Open Championship",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-07-15 08:00:00",
    ends_at: "2026-07-15 18:00:00",
    description: "The biggest intermediate competition of the season.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Championship A", url: CLIMB_URL },
      { name: "Championship B", url: CLIMB_URL },
      { name: "Championship C", url: CLIMB_URL }
    ]
  },
  {
    name: "Summer Sendoff Extravaganza",
    v_grade_min: 7, v_grade_max: 9,
    starts_at: "2026-08-15 09:00:00",
    ends_at: "2026-08-15 19:00:00",
    description: "End of summer party climb! Great vibes and stiff competition.",
    climb_grades: %w[V7 V8 V9],
    climbs: [
      { name: "Sendoff Problem 1", url: CLIMB_URL },
      { name: "Sendoff Problem 2", url: CLIMB_URL },
      { name: "Sendoff Problem 3", url: CLIMB_URL }
    ]
  },
  {
    name: "Master Class Elite Session",
    v_grade_min: 10, v_grade_max: 16,
    starts_at: "2026-08-10 15:00:00",
    ends_at: "2026-08-10 23:00:00",
    description: "Only the absolute best climbers in the world can hang.",
    climb_grades: %w[V10 V12 V14],
    climbs: [
      { name: "World Class 1", url: CLIMB_URL },
      { name: "World Class 2", url: CLIMB_URL },
      { name: "World Class 3", url: CLIMB_URL }
    ]
  },
  {
    name: "Gym Wars: East vs West",
    v_grade_min: 4, v_grade_max: 6,
    starts_at: "2026-08-05 13:00:00",
    ends_at: "2026-08-05 20:00:00",
    description: "Team-based competition between regional gym networks.",
    climb_grades: %w[V4 V5 V6],
    climbs: [
      { name: "Team Problem 1", url: CLIMB_URL },
      { name: "Team Problem 2", url: CLIMB_URL },
      { name: "Team Problem 3", url: CLIMB_URL }
    ]
  }
]

competitions = []
competitions_data.each do |data|
  climb_grades = data.delete(:climb_grades)
  climbs = data.delete(:climbs)
  starts_at = Time.zone.parse(data.delete(:starts_at)) + SEED_DATE_OFFSET
  ends_at = Time.zone.parse(data.delete(:ends_at)) + SEED_DATE_OFFSET
  climbs_attributes = climbs.each_with_index.to_h do |climb, i|
    [ i.to_s, climb.merge(grading: climb_grades[i % climb_grades.length]) ]
  end

  comp = users.sample.owned_competitions.create!(
    data.merge(
      starts_at: starts_at,
      ends_at: ends_at,
      climbs_attributes: climbs_attributes,
      flash_points: 30,
      attempt_deduction: 10
    )
  )

  competitions << comp
end

puts "Created #{competitions.count} competitions with climbs"

# Create enrollments
competitions.each do |comp|
  users.sample(rand(2..6)).each do |user|
    Enrollment.find_or_create_by!(user: user, competition: comp)
  end
end

puts "Created enrollments for realistic participation"

# Create attempts so leaderboards have meaningful rankings
primary_attempt_counts = [ 1, 1, 2, 1, 3, 1, 2, 1 ]

competitions.each do |comp|
  users_in_comp = comp.users.sort_by { |u| u.username.downcase }
  climbs = comp.climbs.order(:id).to_a
  next if climbs.empty?

  users_in_comp.each_with_index do |user, index|
    Attempt.create!(
      user: user,
      climb: climbs.first,
      attempt_count: primary_attempt_counts[index % primary_attempt_counts.length],
      completed: true
    )

    next unless climbs.second.present? && index.even?

    Attempt.create!(
      user: user,
      climb: climbs.second,
      attempt_count: 3,
      completed: false
    )
  end
end

puts "Created attempts for leaderboard rankings"
puts "\nSeed data complete!"
puts "Sample login credentials:"
puts "  Email: alex@climbing.local | Password: password123"
puts "  Email: jordan@climbing.local | Password: password123"
