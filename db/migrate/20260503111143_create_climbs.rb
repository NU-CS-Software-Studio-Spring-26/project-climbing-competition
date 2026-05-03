class CreateClimbs < ActiveRecord::Migration[8.1]
  def change
    create_table :climbs do |t|
      t.string :name
      t.string :url
      t.references :competition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
