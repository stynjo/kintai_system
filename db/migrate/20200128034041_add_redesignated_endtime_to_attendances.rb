class AddRedesignatedEndtimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :redesignated_endtime, :datetime
  end
end
