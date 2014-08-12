FactoryGirl.define do
  factory :parent_guardian_contact do
    user_id      -1
    name         "default_name"
    relationship "default_relationship"
    email        "default@email.com"
    phone        "555-555-5555"
  end
end
