json.extract! competition,
              :id, :name, :description, :competition_start, :competition_end,
              :difficulty, :owner_id, :created_at, :updated_at
json.url competition_url(competition, format: :json)
