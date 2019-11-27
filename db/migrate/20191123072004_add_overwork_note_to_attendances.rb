class AddOverworkNoteToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_note, :string
  end
end
