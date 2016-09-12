include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :event do
    book 

    name { Faker::Name.name  }
    age { Faker::Number.between(3, 18) }
    book_name { Faker::Book.name }
    count { Faker::Number.between(1, 3) }
    words { Faker::Lorem.words(count).join(" ") }
    event_type { 1 }
    user_id { 1 }

    factory :event_with_user_words do
      transient do
        # XXXX is declared as a transient attribute and available in
        # attributes on the factory, as well as the callback via the evaluator
      end

      after(:create) do |event, evaluator|
        #puts "--- after create '#{event.words}'"
        #create_list(:user_word, event.count, event: event)
        event.words.split(" ").each do |word|
          #puts "------ after create #{word}"
          w = create(:word, name: word.strip)
          create(:user_word, event:event, word: w)
        end
      end
    end
  end
end