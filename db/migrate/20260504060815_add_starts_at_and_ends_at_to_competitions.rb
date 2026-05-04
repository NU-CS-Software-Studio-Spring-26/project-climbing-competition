class AddStartsAtAndEndsAtToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :starts_at, :datetime
    add_column :competitions, :ends_at, :datetime
  end
end
