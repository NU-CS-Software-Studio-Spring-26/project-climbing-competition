class AddOwnerToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_reference :competitions, :owner, foreign_key: { to_table: :users }, null: true
  end
end
