class ModifyBooknameInEvents < ActiveRecord::Migration
  def change
    rename_column :events, :book, :book_name
  end
end
