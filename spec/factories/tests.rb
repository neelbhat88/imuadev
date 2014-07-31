# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :org_test do
    organization_id -10
    title           "default_title"
    score_type      0
    description     "default_description"
  end

  factory :user_test do
    org_test_id  1
    user_id      1
    time_unit_id 1
    date         Date.today # TODO Potential errors if tests run at midnight
  end
end
