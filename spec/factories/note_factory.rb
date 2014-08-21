FactoryGirl.define do
  factory :note do
    title 'Phone bill'
    money 1.61
    association :month
  end
end