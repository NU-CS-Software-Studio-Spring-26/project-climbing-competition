# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_07_000001) do
  create_table "attempts", force: :cascade do |t|
    t.integer "attempt_count", null: false
    t.integer "climb_id", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["climb_id"], name: "index_attempts_on_climb_id"
    t.index ["user_id", "climb_id"], name: "index_attempts_on_user_id_and_climb_id", unique: true
    t.index ["user_id"], name: "index_attempts_on_user_id"
    t.check_constraint "attempt_count >= 1 AND attempt_count <= 100", name: "attempt_count_between_1_and_100"
  end

  create_table "climbs", force: :cascade do |t|
    t.integer "angle"
    t.integer "ascents_count", default: 0
    t.string "boardsesh_url"
    t.integer "competition_id", null: false
    t.datetime "created_at", null: false
    t.decimal "difficulty_average", precision: 5, scale: 2
    t.string "frames"
    t.string "grading", null: false
    t.json "hold_assignments", default: {}, null: false
    t.string "kilter_uuid"
    t.string "layout_slug", default: "original"
    t.string "name", null: false
    t.decimal "quality_average", precision: 3, scale: 2
    t.string "setter_username"
    t.string "size_slug", default: "12x12-square"
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.index ["competition_id"], name: "index_climbs_on_competition_id"
    t.index ["kilter_uuid"], name: "index_climbs_on_kilter_uuid", unique: true, where: "kilter_uuid IS NOT NULL"
  end

  create_table "competitions", force: :cascade do |t|
    t.integer "attempt_deduction", default: 5, null: false
    t.date "competition_end"
    t.date "competition_start"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "difficulty", default: 0, null: false
    t.datetime "ends_at", null: false
    t.integer "flash_points", default: 30, null: false
    t.string "level"
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.integer "send_points", default: 25, null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.integer "v_grade_max", null: false
    t.integer "v_grade_min", null: false
    t.index ["owner_id"], name: "index_competitions_on_owner_id"
    t.check_constraint "attempt_deduction >= 0 AND attempt_deduction <= 10000", name: "attempt_deduction_range"
    t.check_constraint "flash_points > 0 AND flash_points <= 10000", name: "flash_points_range"
    t.check_constraint "send_points > 0 AND send_points <= 10000", name: "send_points_range"
    t.check_constraint "v_grade_max >= 0 AND v_grade_max <= 16", name: "v_grade_max_range"
    t.check_constraint "v_grade_max >= v_grade_min", name: "v_grade_max_gte_min"
    t.check_constraint "v_grade_min >= 0 AND v_grade_min <= 16", name: "v_grade_min_range"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["competition_id"], name: "index_enrollments_on_competition_id"
    t.index ["user_id", "competition_id"], name: "index_enrollments_on_user_id_and_competition_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "followed_id", null: false
    t.integer "follower_id", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "kilter_placement_roles", force: :cascade do |t|
    t.string "color_hex", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_kilter_placement_roles_on_role_id", unique: true
  end

  create_table "kilter_placements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hole_id"
    t.string "layout_slug", default: "original", null: false
    t.integer "placement_id", null: false
    t.datetime "updated_at", null: false
    t.integer "x", null: false
    t.integer "y", null: false
    t.index ["layout_slug", "placement_id"], name: "index_kilter_placements_on_layout_slug_and_placement_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", limit: 45
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", limit: 512
    t.integer "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email_address", limit: 254
    t.string "google_uid"
    t.string "name", limit: 80
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username", limit: 30
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "attempts", "climbs"
  add_foreign_key "attempts", "users"
  add_foreign_key "climbs", "competitions"
  add_foreign_key "competitions", "users", column: "owner_id"
  add_foreign_key "enrollments", "competitions"
  add_foreign_key "enrollments", "users"
  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "identities", "users"
  add_foreign_key "sessions", "users"
end
