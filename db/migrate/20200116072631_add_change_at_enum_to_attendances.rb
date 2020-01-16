class AddChangeAtEnumToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_at_enum, :integer, default: 1
  end
end
