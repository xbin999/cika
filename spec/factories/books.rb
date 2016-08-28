include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :book do
    name { Faker::Book.title }
    author { Faker::Book.author }
    press { Faker::Book.publisher }
    cover { fixture_file_upload(Rails.root.join('spec', 'photos', 'testcover.jpg'), 'image/png') }
  end
end