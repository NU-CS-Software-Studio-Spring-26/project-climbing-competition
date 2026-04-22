class AddDescriptionToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :description, :text
  end
end
