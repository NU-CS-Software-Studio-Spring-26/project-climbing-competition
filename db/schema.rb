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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_233000) do
  create_table "competitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "name"
    t.integer "owner_id"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_competitions_on_owner_id"
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

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "username"
  end

  add_foreign_key "competitions", "users", column: "owner_id"
  add_foreign_key "enrollments", "competitions"
  add_foreign_key "enrollments", "users"
end
