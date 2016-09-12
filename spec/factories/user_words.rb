FactoryGirl.define do
  # user_word factory with a `belongs_to` association for the event
  factory :user_word do
    user_id {1}
    word
    book_id {1}
    event
    sentence { Faker::Lorem.words }
  end
end
