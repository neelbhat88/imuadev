# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment do
    user_id      -10
    title        "default_title"
    description  "default_description"
    due_datetime DateTime.now
    organization_id -10
  end

  factory :user_assignment do
    assignment_id 1
    user_id       1
    status        0
  end
end
