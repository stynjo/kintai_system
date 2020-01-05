class AddMontlyRequestChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_request_change, :boolean, deafult: false
  end
end
