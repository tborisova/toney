FactoryGirl.define do
  factory :user do
    sequence(:email, 1000) { |n| "example#{n}@example.com"}
    password 'PAssword'
    password_confirmation 'PAssword'
  end
end