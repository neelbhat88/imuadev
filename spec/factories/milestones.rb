FactoryGirl.define do
  factory :milestone do
    self.module Constants.Modules[:ACADEMICS]
    submodule Constants.SubModules[:ACADEMICS_GPA]
    title "Milestone title"
    description "Milestone description"
    value "milestone value"
    icon "milestone icon"
    time_unit_id -1
    importance 1
    points 10
    organization_id -1

    factory :gpa_milestone do
      self.module Constants.Modules[:ACADEMICS]
      submodule Constants.SubModules[:ACADEMICS_GPA]
    end

  end

  factory :user_milestone do
    self.module Constants.Modules[:ACADEMICS]
    submodule Constants.SubModules[:ACADEMICS_GPA]
    time_unit_id -1
    user_id -1
    milestone_id -1
  end
end
