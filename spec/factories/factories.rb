FactoryGirl.define do
  factory :user do
    first_name "Test"
    last_name "Test"
    sequence(:email) { |n| "test#{n}@test.com"}
    password "password"
    role -10
    organization_id -10

    factory :org_admin do
      role 10
    end

    factory :student do
      time_unit_id -5
      role 50
    end

    factory :mentor do
      role 40
    end

    factory :super_admin do
      role 0
      organization_id 0
    end
  end

  factory :organization do
    name "Test Org"
  end

  factory :user_class do
    gpa 4.0
    grade "A"
    name "Test Class"
    time_unit_id 1
    user_id -1
  end
end
