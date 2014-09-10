# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_gpa_history do
    user_gpa_id 1
    user_id 1
    core_unweighted 1.5
    core_weighted 1.5
    regular_weighted 1.5
    regular_unweighted 1.5
    time_unit_id 1
  end
end
