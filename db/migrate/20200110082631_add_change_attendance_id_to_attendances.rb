class AddChangeAttendanceIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendance_id, :integer
  end
end
