# frozen_string_literal: true

# Shared helpers for db/seeds.rb and db/seeds/large.rb
module SeedSupport
  SEED_CLIMB_URL = "https://portal.kiltergrips.com/search/climbs?angle=40&climbUuid=D0E5387D5B974D38B4E93FC4DFD61EF6"
  SEED_PASSWORD = "password123"
  SEED_EMAIL_DOMAIN = "climbing.local"

  GRADE_BY_LEVEL = {
    "beginner" => %w[V2 V3 V4],
    "intermediate" => %w[V4 V5 V6],
    "advanced" => %w[V6 V7 V8],
    "elite" => %w[V8 V9 V10]
  }.freeze

  LEVEL_LABELS = {
    "beginner" => "Beginner",
    "intermediate" => "Intermediate",
    "advanced" => "Advanced",
    "elite" => "Elite"
  }.freeze

  FIRST_NAMES = %w[
    Alex Jordan Morgan Casey Parker Riley Avery Taylor Sam Quinn Reese
    Dakota Skyler Jamie Avery Logan Blake Cameron Drew Elliot Finley
    Harper Jesse Kai Lane Marley Nico Oakley Peyton River Sage Tatum
    Wren Zion Adriana Bianca Carlos Diana Elena Felix Gina Hugo Ines
  ].freeze

  LAST_NAMES = %w[
    Rivera Chen Lee Thompson Davis Kim Johnson Brown Martinez Garcia
    Wilson Anderson Thomas Jackson White Harris Martin Thompson Moore
    Taylor Clark Lewis Walker Hall Allen Young King Wright Lopez Hill
    Scott Green Adams Baker Nelson Carter Mitchell Perez Roberts Turner
  ].freeze

  BIOS = [
    "V-grader and spray beta enthusiast",
    "Boulderer from the Bay Area",
    "Speed climber | Competition junkie",
    "Outdoor crag rat, indoor gym lover",
    "Route setter by day, climber by night",
    "Training for nationals",
    "Youth competitive climber",
    "Problem solver and crimper",
    "Campus board enthusiast",
    "Dyno or die",
    "Sloper specialist",
    "Weekend crusher, weekday desk jockey",
    "Film every send, delete every fall",
    "Kilter board regular",
    "Chasing the next grade"
  ].freeze

  CLIMB_NAMES = [
    "Slopers Warm-up", "Jug Ladder", "Topout Finish", "Crimpy Sequence",
    "Dyno to Sloper", "Compression Cave", "Warm-up Jugs", "Easy Slopers",
    "Confidence Builder", "Mid-Grade Crimps", "Dynamic Jumpers",
    "Powerful Pockets", "Endurance Challenge", "Precision Finale",
    "Speed Boulder", "Final Burn", "Mega Volume", "Slope Master",
    "Pocket Paradise", "Launch Sequence"
  ].freeze

  SEASONS = %w[Spring Summer Fall Winter].freeze
  DESCRIPTORS = %w[
    Send\ Fest Boulder\ Bash Open Qualifier Invitational Championship
    Series Showdown Classic Challenge Festival Showdown
  ].freeze
  REGIONS = %w[Midwest West\ Coast Bay\ Area Regional Local\ Gym Campus\ Board].freeze
  STYLES = %w[Women's Youth Speed Technical Volume Sloper Dynamics].freeze
  EVENT_TYPES = %w[Open Championship Qualifier Session Classic].freeze
  GYM_STYLES = %w[Local\ Gym Home\ Gym Community].freeze
  NAME_SUFFIXES = %w[II III West East North South Classic Encore].freeze

  DESCRIPTIONS_BY_LEVEL = {
    "beginner" => [
      "Open to climbers new to competition. Great atmosphere and plenty of cheering!",
      "Casual comp with fun prizes. Perfect for your first competition!",
      "Learn comp format and climb with other beginners. No pressure, all fun!",
      "All about building confidence in a supportive environment."
    ],
    "intermediate" => [
      "Qualifying round for nationals. All skill levels welcome.",
      "Friendly competition at our home gym. Food trucks and live music!",
      "Build your skills and compete with climbers at your level.",
      "Fast-paced qualifier round with multiple heats throughout the day."
    ],
    "advanced" => [
      "For climbers with solid experience. Tough problems and great vibes.",
      "Focused on technical movement and problem solving.",
      "Long format competition testing stamina and mental strength.",
      "Test your jumping and dynamic movement skills against the best."
    ],
    "elite" => [
      "Invite-only competition for top climbers. Fierce competition.",
      "Timed speed climbing event. Clock is your competitor.",
      "Extreme power test. Elite climbers only.",
      "Only the absolute best climbers can hang."
    ]
  }.freeze

  module_function

  def derive_username(first_name, last_name, used_usernames)
    base = "#{first_name}#{last_name}".downcase.gsub(/[^a-z0-9_.-]/, "")
    base = "climber" if base.empty?
    candidate = base[0, User::USERNAME_MAX_LENGTH]

    20.times do
      return register_username(candidate, used_usernames) unless used_usernames.include?(candidate.downcase)

      suffix = rand(10..99).to_s
      candidate = "#{base[0, User::USERNAME_MAX_LENGTH - suffix.length]}#{suffix}"
    end

    register_username("user#{rand(100_000..999_999)}", used_usernames)
  end

  def register_username(username, used_usernames)
    used_usernames << username.downcase
    username
  end

  def generate_user_attributes(used_usernames:, used_emails:, with_bio: nil)
    first_name = FIRST_NAMES.sample
    last_name = LAST_NAMES.sample
    name = "#{first_name} #{last_name}"
    username = derive_username(first_name, last_name, used_usernames)
    email_address = "#{username}@#{SEED_EMAIL_DOMAIN}"

    until used_emails.exclude?(email_address.downcase)
      username = derive_username(first_name, last_name, used_usernames)
      email_address = "#{username}@#{SEED_EMAIL_DOMAIN}"
    end
    used_emails << email_address.downcase

    bio = if with_bio.nil?
      rand < 0.7 ? BIOS.sample : nil
    elsif with_bio
      BIOS.sample
    end

    {
      name: name,
      username: username,
      email_address: email_address,
      bio: bio
    }
  end

  def generate_competition_name(level:, year:, used_names:)
    10.times do
      name = build_competition_name(level: level, year: year)
      next if used_names.include?(name)

      used_names << name
      return name
    end

    suffix = NAME_SUFFIXES.sample
    name = "#{build_competition_name(level: level, year: year)} — #{suffix}"
    used_names << name
    name
  end

  def build_competition_name(level:, year:)
    level_label = LEVEL_LABELS.fetch(level)

    case rand(5)
    when 0
      "#{SEASONS.sample} #{DESCRIPTORS.sample} #{year}"
    when 1
      "#{REGIONS.sample} #{level_label} Championship"
    when 2
      "#{STYLES.sample} Boulder #{EVENT_TYPES.sample}"
    when 3
      "#{DESCRIPTORS.sample} Series — Round #{rand(1..12)}"
    else
      "#{GYM_STYLES.sample} #{level_label} Open"
    end
  end

  def generate_competition_description(level)
    DESCRIPTIONS_BY_LEVEL.fetch(level).sample
  end

  def sample_climb_names(count: 2)
    CLIMB_NAMES.sample(count)
  end

  def grades_for_level(level, count: 2)
    grades = GRADE_BY_LEVEL.fetch(level)
    Array.new(count) { |index| grades[index % grades.length] }
  end

  def competition_window(index, total:)
    # Spread competitions across past, active, and upcoming windows.
    offset_days = (index % total) - (total / 2)
    starts_at = Time.current + offset_days.days + rand(0..8).hours
    ends_at = starts_at + rand(6..14).hours
    [ starts_at, ends_at ]
  end
end
