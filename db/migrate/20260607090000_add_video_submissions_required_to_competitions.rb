class AddVideoSubmissionsRequiredToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :video_submissions_required, :boolean, null: false, default: false
  end
end
