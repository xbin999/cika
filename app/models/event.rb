# encoding: utf-8
class NewCardValidator < ActiveModel::Validator
  def validate(record)
    unless (!record.words.blank? && record.event_type == "newcard")
      record.errors[:words] << '不能为空！'
    end
  end
end

class Event < ActiveRecord::Base
  belongs_to :book
  has_many :user_words

  validates_presence_of :name
  include ActiveModel::Validations
  validates_with NewCardValidator  
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
