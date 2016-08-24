class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.string :author
      t.string :isbn
      t.string :press
      t.text   :description
      t.float :grade_level
      t.integer :lexile_level
      t.string :douban_link
      t.string :scholastic_link

      t.timestamps null: false
    end
  end
end
