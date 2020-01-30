class AddEditOneMonthTomorrowToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_one_month_tomorrow, :boolean
  end
end
