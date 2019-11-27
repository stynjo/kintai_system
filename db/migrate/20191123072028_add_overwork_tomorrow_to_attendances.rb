class AddOverworkTomorrowToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_tomorrow, :boolean
  end
end
