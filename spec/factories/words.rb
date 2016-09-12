FactoryGirl.define do
  factory :word do
    name {Faker::Lorem.word}
    explains {Faker::Lorem.sentence}
  end
end
