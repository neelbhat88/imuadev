FactoryGirl.define do
  factory :user_class do
    gpa 4.0
    grade "A"
    grade_value 95.0
    name "Test Class"
    time_unit_id 1
    user_id -1
    credit_hours 1
    level 'Regular'
  end
end
