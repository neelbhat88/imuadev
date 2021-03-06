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

  factory :user_service_organization do
    name "Test Service Organization"
    description ""
    user_id -1
  end

  factory :user_service_hour do
    user_service_organization_id -1
    name "Test Service Activity Hour"
    hours 10
    description ""
    date "2014/08/01"
    time_unit_id 1
    user_id -1
  end

  factory :user_extracurricular_activity do
    name "Test Extracurricular Activity"
    description ""
    user_id -1
  end

  factory :user_extracurricular_activity_detail do
    user_extracurricular_activity_id -1
    name "Test Extracurricular Activity Detail"
    leadership ""
    description ""
    time_unit_id 1
    user_id -1
  end

end
