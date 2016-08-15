class Event < ActiveRecord::Base
  validates_presence_of :name, :words
  validates_numericality_of :age, :greater_than_or_equal_to => 1  
end
