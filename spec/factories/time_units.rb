# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_unit do
    name "Time Unit"
    organization_id -1
    roadmap_id -1
  end
end
