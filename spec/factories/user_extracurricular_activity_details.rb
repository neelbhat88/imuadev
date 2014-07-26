# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_extracurricular_activity_detail do
    extracurricular_activity_id 1
    position "MyString"
    description "MyString"
    user_id 1
  end
end
