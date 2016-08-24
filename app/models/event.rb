# encoding: utf-8

class Event < ActiveRecord::Base
  belongs_to :book

  validates_presence_of :name
  #validates_numericality_of :age, :greater_than_or_equal_to => 1  

  enum event_type: [:reserve, :newcard, :newbook]

  def to_view_str
    case event_type
    when "newcard"
      "@#{name} 制作了《#{book_name}》书中的#{count || words.split(" ").count}张单词卡片。"
    when "newbook"
      "@#{name} 新增了《#{book_name}》一书。"
    else
      "@#{name} @《#{book_name}》。"
    end
  end
end
