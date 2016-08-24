class AddPagenumberToBooks < ActiveRecord::Migration
  def change
    add_column :books, :page_number, :integer
  end
end
