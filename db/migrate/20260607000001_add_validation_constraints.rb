class AddValidationConstraints < ActiveRecord::Migration[8.1]
  SCORING_MAX = 10_000

  def up
    change_column :climbs, :url, :text

    change_column :users, :name, :string, limit: 80
    change_column :users, :username, :string, limit: 30
    change_column :users, :email_address, :string, limit: 254

    change_column :sessions, :ip_address, :string, limit: 45
    change_column :sessions, :user_agent, :string, limit: 512

    backfill_competition_required_fields
    backfill_climb_required_fields

    change_column_null :competitions, :name, false
    change_column_null :competitions, :starts_at, false
    change_column_null :competitions, :ends_at, false
    change_column_null :competitions, :owner_id, false

    change_column_null :climbs, :name, false
    change_column_null :climbs, :url, false
    change_column_null :climbs, :grading, false

    add_check_constraint :competitions,
      "send_points > 0 AND send_points <= #{SCORING_MAX}",
      name: "send_points_range"
    add_check_constraint :competitions,
      "flash_points > 0 AND flash_points <= #{SCORING_MAX}",
      name: "flash_points_range"
    add_check_constraint :competitions,
      "attempt_deduction >= 0 AND attempt_deduction <= #{SCORING_MAX}",
      name: "attempt_deduction_range"
  end

  def down
    remove_check_constraint :competitions, name: "attempt_deduction_range"
    remove_check_constraint :competitions, name: "flash_points_range"
    remove_check_constraint :competitions, name: "send_points_range"

    change_column_null :climbs, :grading, true
    change_column_null :climbs, :url, true
    change_column_null :climbs, :name, true

    change_column_null :competitions, :owner_id, true
    change_column_null :competitions, :ends_at, true
    change_column_null :competitions, :starts_at, true
    change_column_null :competitions, :name, true

    change_column :sessions, :user_agent, :string
    change_column :sessions, :ip_address, :string

    change_column :users, :email_address, :string
    change_column :users, :username, :string
    change_column :users, :name, :string

    change_column :climbs, :url, :string
  end

  private

  def backfill_competition_required_fields
    execute <<~SQL.squish
      UPDATE competitions
      SET name = COALESCE(name, 'Untitled Competition'),
          starts_at = COALESCE(starts_at, created_at, CURRENT_TIMESTAMP),
          ends_at = COALESCE(ends_at, starts_at, created_at, CURRENT_TIMESTAMP)
      WHERE name IS NULL OR starts_at IS NULL OR ends_at IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE competitions
      SET owner_id = (SELECT id FROM users ORDER BY id LIMIT 1)
      WHERE owner_id IS NULL
    SQL
  end

  def backfill_climb_required_fields
    execute <<~SQL.squish
      UPDATE climbs
      SET name = COALESCE(name, 'Untitled Climb'),
          url = COALESCE(url, 'https://example.com'),
          grading = COALESCE(grading, 'V0')
      WHERE name IS NULL OR url IS NULL OR grading IS NULL
    SQL
  end
end
