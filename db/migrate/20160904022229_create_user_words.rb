class CreateUserWords < ActiveRecord::Migration
  def change
    create_table :user_words do |t|
      t.integer :word_id
      t.integer :book_id
      t.integer :user_id
      t.integer :event_id
      t.string :sentence

      t.timestamps null: false
    end
  end
end
