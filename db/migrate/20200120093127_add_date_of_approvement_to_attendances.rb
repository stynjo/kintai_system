class AddDateOfApprovementToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :date_of_approvement, :datetime
  end
end
