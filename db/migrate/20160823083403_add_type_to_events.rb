class AddTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_type, :integer
    execute "UPDATE events SET event_type=1 WHERE event_type IS NULL;" 
  end

end
