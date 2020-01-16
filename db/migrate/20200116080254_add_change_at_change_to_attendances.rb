class AddChangeAtChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_at_change, :boolean
  end
end
