class AddOverworkEnumToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_enum, :integer, default: 1
  end
end
