class CreateCompetitions < ActiveRecord::Migration[8.1]
  def change
    create_table :competitions do |t|
      t.string :name
      t.date :date

      t.timestamps
    end
  end
end
