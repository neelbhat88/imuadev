# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expectation do
    organization_id 1
    title           "default_title"
    description     "default_description"
    rank            0
  end

  factory :user_expectation do
    expectation_id 1
    user_id        1
    status         1
  end
end
