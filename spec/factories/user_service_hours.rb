# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_service_hour do
    service_org_id 1
    hours "9.99"
    date "2014-07-21"
    user_id 1
  end
end
