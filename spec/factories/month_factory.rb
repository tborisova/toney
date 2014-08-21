FactoryGirl.define do
  factory :month do
    sequence(:start) { |n| n.months.ago }
    sequence(:end) { |n| n.months.ago }
    money 1.61
    association :user
  end
end