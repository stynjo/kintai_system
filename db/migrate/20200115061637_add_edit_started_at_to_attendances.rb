class AddEditStartedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_started_at, :datetime
  end
end
