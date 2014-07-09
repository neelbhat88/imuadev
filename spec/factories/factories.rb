FactoryGirl.define do
  factory :org_admin, class: User do
    first_name "OrgAdmin"
    last_name "Test"
    email "oa-test@gmail.com"
    password "password"
    organization_id -10
    role 10
  end

  factory :student, class: User do
    first_name "Student"
    last_name "Test"
    email "student-test@gmail.com"
    password "password"
    organization_id -10
    time_unit_id -5
    role 50
  end

  factory :mentor, class: User do
    first_name "Mentor"
    last_name "Test"
    email "mentor-test@gmail.com"
    password "password"
    organization_id -10
    role 40
  end

  factory :super_admin, class: User do
    first_name "SuperAdmin"
    last_name "Test"
    email "sa-test@gmail.com"
    password "password"
    organization_id -10
    role 0
  end
end
