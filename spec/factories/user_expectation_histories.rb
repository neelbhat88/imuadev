# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_expectation_history do
    expectation_id 1
    user_expectation_id 1
    modified_by_id 1
    modified_by_name "Bruh"
    user_id 1
    updated_at "2014-09-03 12:13:26"
    status 1
    title "MyString"
    rank 1
  end
end
