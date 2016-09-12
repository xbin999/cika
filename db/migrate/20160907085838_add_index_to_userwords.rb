class AddIndexToUserwords < ActiveRecord::Migration
  def change
    add_index :user_words, :event_id
    change_column :user_words, :word_id, :integer, :null => false
  end
end
