class AddNumberToBases < ActiveRecord::Migration[5.1]
  def change
    add_column :bases, :number, :integer
  end
end
