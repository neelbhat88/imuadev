# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    message "MyText"
    type 1
    date "2015-05-19 14:01:20"
    time_spent "9.99"
    created_by 1
    user_id 1
    is_private false
  end
end
