class AddGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :integer, :default => 0
    add_column :users, :birthday, :date
    add_column :users, :last_vocab_level, :integer

    add_index :users, :name, :unique => true
  end
end
