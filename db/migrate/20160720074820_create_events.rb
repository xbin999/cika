class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.integer :age
      t.string :book
      t.text :words

      t.timestamps null: false
    end
  end
end
