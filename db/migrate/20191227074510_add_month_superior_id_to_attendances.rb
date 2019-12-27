class AddMonthSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_superior_id, :integer
  end
end
