# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

20.times do |i|
  Competition.create!(
    name: "Comp #{i + 1}",
    date: "2026-04-#{(i % 30) + 1}"
  )
end

20.times do |i|
  User.create!(
    name: "User #{i + 1}",
    username: "username#{i + 1}"
  )
end