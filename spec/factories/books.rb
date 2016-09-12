include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :book do
    name { Faker::Book.title }
    author { Faker::Book.author }
    press { Faker::Book.publisher }
    #cover { File.new("#{Rails.root}/spec/photos/testcover.jpg") }
    cover_file_name {"testcover.jpg"}
    cover_content_type {"image/png"}
    cover_file_size {1024}

    factory :book_with_upload do
      cover { fixture_file_upload(Rails.root.join('spec', 'photos', 'testcover.jpg'), 'image/png') }
    end
  end
end