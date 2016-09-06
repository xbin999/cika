class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.string :phonetic
      t.string :us_phonetic
      t.string :uk_phonetic
      t.string :explains
      t.string :translate_type
      t.string :translate_tool

      t.timestamps null: false
    end
  end
end
