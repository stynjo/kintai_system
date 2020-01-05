class AddMonthlyEnumToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_enum, :integer, default: 1
  end
end
