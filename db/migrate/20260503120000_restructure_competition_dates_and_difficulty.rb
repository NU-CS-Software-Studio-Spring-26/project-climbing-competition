class RestructureCompetitionDatesAndDifficulty < ActiveRecord::Migration[8.1]
  def up
    add_column :competitions, :competition_start, :date
    add_column :competitions, :competition_end, :date
    add_column :competitions, :difficulty, :integer, null: false, default: 0

    Competition.reset_column_information
    Competition.find_each do |competition|
      d = competition.read_attribute(:date)
      competition.update_columns(
        competition_start: d,
        competition_end: d
      )
    end

    remove_column :competitions, :date
  end

  def down
    add_column :competitions, :date, :date

    Competition.reset_column_information
    Competition.find_each do |competition|
      competition.update_columns(date: competition.read_attribute(:competition_end))
    end

    remove_column :competitions, :difficulty
    remove_column :competitions, :competition_end
    remove_column :competitions, :competition_start
  end
end
