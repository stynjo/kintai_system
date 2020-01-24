class RemoveBasicTimeFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :basic_time, :datetime
  end
end
