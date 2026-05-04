# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
User.destroy_all
Competition.destroy_all

# Create users
users_data = [
  { name: "Alex Rivera", username: "alexrivera", email: "alex@climbing.local", bio: "V-grader and spray beta enthusiast 🧗" },
  { name: "Jordan Chen", username: "jordanclimbs", email: "jordan@climbing.local", bio: "Boulderer from the Bay Area" },
  { name: "Morgan Lee", username: "morganflash", email: "morgan@climbing.local", bio: "Speed climber | Competition junkie" },
  { name: "Casey Thompson", username: "caseyboulds", email: "casey@climbing.local", bio: "Outdoor crag rat, indoor gym lover" },
  { name: "Parker Davis", username: "parkersends", email: "parker@climbing.local", bio: "Route setter by day, climber by night" },
  { name: "Riley Kim", username: "rileybeta", email: "riley@climbing.local", bio: "Training for nationals" },
  { name: "Avery Johnson", username: "averyclimbs", email: "avery@climbing.local", bio: "Youth competitive climber" },
  { name: "Taylor Brown", username: "taylorboulder", email: "taylor@climbing.local", bio: "Problem solver and crimper" }
]

users = users_data.map do |data|
  User.create!(
    name: data[:name],
    username: data[:username],
    email_address: data[:email],
    bio: data[:bio],
    password: "password123"
  )
end

puts "Created #{users.length} users"

# Create competitions with climbs
competitions_data = [
  {
    name: "Spring Send Fest 2026",
    level: "beginner",
    starts_at: "2026-05-15 09:00:00",
    ends_at: "2026-05-15 17:00:00",
    description: "Open to climbers new to competition. Great atmosphere and plenty of cheering!",
    climbs: [
      { name: "Slopers Warm-up", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Jug Ladder", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Midwest Regional Championship",
    level: "intermediate",
    starts_at: "2026-06-02 08:00:00",
    ends_at: "2026-06-02 18:00:00",
    description: "Qualifying round for nationals. All skill levels welcome.",
    climbs: [
      { name: "Crimpy Sequence", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Dyno to Sloper", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Elite Nationals Qualifier",
    level: "elite",
    starts_at: "2026-07-20 10:00:00",
    ends_at: "2026-07-20 20:00:00",
    description: "Invite-only competition for top climbers. Tough problems and fierce competition.",
    climbs: [
      { name: "One-Finger Pocket Nightmare", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Volume to Dyno Sprint", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Summer Boulder Bash",
    level: "beginner",
    starts_at: "2026-06-10 09:00:00",
    ends_at: "2026-06-10 16:00:00",
    description: "Casual comp with fun prizes. Perfect for your first competition!",
    climbs: [
      { name: "Warm-up Jugs", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Easy Slopers", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Advanced Youth Open",
    level: "advanced",
    starts_at: "2026-05-28 10:00:00",
    ends_at: "2026-05-28 17:00:00",
    description: "For climbers aged 13-18 with solid climbing experience.",
    climbs: [
      { name: "Tiny Edges Test", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Compression Master", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Local Gym Championship",
    level: "intermediate",
    starts_at: "2026-05-22 18:00:00",
    ends_at: "2026-05-23 00:00:00",
    description: "Friendly competition at our home gym. Food trucks and live music!",
    climbs: [
      { name: "Mid-Grade Crimps", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Dynamic Jumpers", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Women's Boulder Invitational",
    level: "advanced",
    starts_at: "2026-06-15 09:00:00",
    ends_at: "2026-06-15 18:00:00",
    description: "Celebrating women in climbing. Amazing prize purse and sponsorships.",
    climbs: [
      { name: "Powerful Pockets", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Endurance Challenge", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Beginner Basics Series - Round 1",
    level: "beginner",
    starts_at: "2026-05-10 10:00:00",
    ends_at: "2026-05-10 15:00:00",
    description: "Learn comp format and climb with other beginners. No pressure, all fun!",
    climbs: [
      { name: "Getting Started", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Basic Moves", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "May Madness Bouldering Series",
    level: "intermediate",
    starts_at: "2026-05-31 11:00:00",
    ends_at: "2026-05-31 19:00:00",
    description: "Fast-paced qualifier round with multiple heats throughout the day.",
    climbs: [
      { name: "Speed Boulder", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Power endurance", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Rising Stars Youth Championship",
    level: "beginner",
    starts_at: "2026-06-05 09:00:00",
    ends_at: "2026-06-05 14:00:00",
    description: "For younger climbers just starting their competition journey.",
    climbs: [
      { name: "Youth Jug Haul", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Kid-Friendly Volume", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Technical Tactics Training",
    level: "advanced",
    starts_at: "2026-06-18 15:00:00",
    ends_at: "2026-06-18 22:00:00",
    description: "Focused on technical movement and problem solving. Advanced techniques only.",
    climbs: [
      { name: "Precision Required", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Balance Master", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Elite Speed Challenge",
    level: "elite",
    starts_at: "2026-07-10 14:00:00",
    ends_at: "2026-07-10 18:00:00",
    description: "Timed speed climbing event. Clock is your competitor.",
    climbs: [
      { name: "Fast Track", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Lightning Route", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Intermediate Skills Workshop",
    level: "intermediate",
    starts_at: "2026-06-20 10:00:00",
    ends_at: "2026-06-20 17:00:00",
    description: "Build your skills and compete with climbers at your level.",
    climbs: [
      { name: "Skill Builder A", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Skill Builder B", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Endurance Fest 2026",
    level: "advanced",
    starts_at: "2026-06-25 08:00:00",
    ends_at: "2026-06-25 20:00:00",
    description: "Long format competition testing stamina and mental strength.",
    climbs: [
      { name: "Long Haul Alpha", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Long Haul Beta", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Regional Qualifier Series",
    level: "intermediate",
    starts_at: "2026-07-05 12:00:00",
    ends_at: "2026-07-05 20:00:00",
    description: "Earn your spot at the nationals through this qualifier event.",
    climbs: [
      { name: "Qualifier Problem 1", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Qualifier Problem 2", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Beginner Confidence Boost",
    level: "beginner",
    starts_at: "2026-06-08 10:00:00",
    ends_at: "2026-06-08 15:00:00",
    description: "All about building confidence in a supportive environment.",
    climbs: [
      { name: "Confidence Builder", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Success Guaranteed", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Campus Board Kings",
    level: "elite",
    starts_at: "2026-07-25 16:00:00",
    ends_at: "2026-07-25 21:00:00",
    description: "Extreme power test on the campus board. Elite climbers only.",
    climbs: [
      { name: "Campus Ladder Extreme", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Power Sprint", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Dynamics Showcase",
    level: "advanced",
    starts_at: "2026-07-08 11:00:00",
    ends_at: "2026-07-08 18:00:00",
    description: "Test your jumping and dynamic movement skills against the best.",
    climbs: [
      { name: "Dyno Gauntlet", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Air Time Challenge", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Pocket Pincher Pro Open",
    level: "elite",
    starts_at: "2026-08-01 09:00:00",
    ends_at: "2026-08-01 17:00:00",
    description: "All-pocket formats challenge. Crimp strength and technique required.",
    climbs: [
      { name: "Pocket Paradise", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Precision Pockets", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Slopers Slammed",
    level: "intermediate",
    starts_at: "2026-06-28 14:00:00",
    ends_at: "2026-06-28 21:00:00",
    description: "All sloper format testing balance and technique.",
    climbs: [
      { name: "Slope Master", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Slope Control", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Volume Vendetta",
    level: "advanced",
    starts_at: "2026-07-12 09:00:00",
    ends_at: "2026-07-12 16:00:00",
    description: "Big volume problems demand big movements. Are you ready?",
    climbs: [
      { name: "Mega Volume", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Size Matters", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Beginner Boulder Bash Encore",
    level: "beginner",
    starts_at: "2026-07-01 10:00:00",
    ends_at: "2026-07-01 15:00:00",
    description: "Popular beginner event is back! Join us again for another round.",
    climbs: [
      { name: "Fun Boulder A", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Fun Boulder B", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Intermediate Open Championship",
    level: "intermediate",
    starts_at: "2026-07-15 08:00:00",
    ends_at: "2026-07-15 18:00:00",
    description: "The biggest intermediate competition of the season.",
    climbs: [
      { name: "Championship A", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Championship B", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Summer Sendoff Extravaganza",
    level: "advanced",
    starts_at: "2026-08-15 09:00:00",
    ends_at: "2026-08-15 19:00:00",
    description: "End of summer party climb! Great vibes and stiff competition.",
    climbs: [
      { name: "Sendoff Problem 1", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Sendoff Problem 2", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Master Class Elite Session",
    level: "elite",
    starts_at: "2026-08-10 15:00:00",
    ends_at: "2026-08-10 23:00:00",
    description: "Only the absolute best climbers in the world can hang.",
    climbs: [
      { name: "World Class 1", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "World Class 2", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  },
  {
    name: "Gym Wars: East vs West",
    level: "intermediate",
    starts_at: "2026-08-05 13:00:00",
    ends_at: "2026-08-05 20:00:00",
    description: "Team-based competition between regional gym networks.",
    climbs: [
      { name: "Team Problem 1", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" },
      { name: "Team Problem 2", url: "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6" }
    ]
  }
]

competitions = []
competitions_data.each do |data|
  climbs = data.delete(:climbs)
  climbs_attributes = {}
  climbs.each_with_index do |climb, index|
    climbs_attributes[index.to_s] = climb
  end

  comp = users[rand(0...users.length)].owned_competitions.create!(
    data.merge(climbs_attributes: climbs_attributes)
  )
  competitions << comp
end

puts "Created #{competitions.count} competitions with climbs"

# Create some enrollments to show realistic participation
competitions.each do |comp|
  # Randomly enroll 2-6 users per competition
  enrolled_count = rand(2..6)
  sample_users = users.sample(enrolled_count)
  sample_users.each do |user|
    Enrollment.find_or_create_by(user: user, competition: comp)
  end
end


# Create attempts so leaderboards have meaningful rankings
primary_attempt_counts = [ 1, 1, 2, 1, 3, 1, 2, 1 ]

competitions.each do |comp|
  users_in_comp = comp.users.sort_by { |user| user.username.downcase }
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
puts "Created enrollments for realistic participation"
puts "\nSeed data complete!"
puts "Created attempts for leaderboard rankings"
puts "Sample login credentials:"
puts "  Email: alex@climbing.local | Password: password123"
puts "  Email: jordan@climbing.local | Password: password123"
