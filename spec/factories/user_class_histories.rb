# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_class_history do
    user_class_id 1
    name "MyString"
    time_unit_id ""
    grade ""
    grade_value 0.0
    gpa ""
    period ""
    room ""
    credit_hours 1.5
    level "MyString"
    subject "MyString"
    user_id 1
  end
end
