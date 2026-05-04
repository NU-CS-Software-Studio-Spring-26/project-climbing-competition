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

puts "Created enrollments for realistic participation"
puts "\nSeed data complete!"
puts "Sample login credentials:"
puts "  Email: alex@climbing.local | Password: password123"
puts "  Email: jordan@climbing.local | Password: password123"
