class AddOverworkSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_superior_id, :integer
  end
end
