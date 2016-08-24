class AddBookidToEvents < ActiveRecord::Migration
  def change
    add_column :events, :book_id, :integer
    add_column :events, :user_id, :integer
  end
end
