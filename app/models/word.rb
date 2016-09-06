# encoding: utf-8

class Word < ActiveRecord::Base
  validates_presence_of :name, :explains
  has_many :user_words

  def to_cover(sentence = nil)
    target ||= []

    if self.translate_type == "英译中"
      target << "us: [#{self.us_phonetic}]  uk: [#{self.uk_phonetic}]"
    else
      if self.phonetic != nil
        target << "[#{self.phonetic}]"
      end
    end
    target << self.explains
    if sentence != nil || sentence != ""
      target << sentence
    end

    return target
  end
end
