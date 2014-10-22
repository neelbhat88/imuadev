require 'rails_helper'

describe Ability do
  it "allows all actions to a super admin" do
    user = build(:super_admin)
    assignment = build(:assignment)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly(:get_assignment,
                                         :update_assignment,
                                         :destroy_assignment,
                                         :get_assignment_collection,
                                         :update_assignment_broadcast)
  end

  it "doesn't allow any action if not in same organization" do
    user = build(:user, organization_id: 1)
    assignment = build(:assignment, organization_id: 3)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly()
  end

  it "allows org admin actions" do
    user = build(:org_admin, organization_id: 1)
    assignment = build(:assignment, organization_id: 1)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly(:get_assignment,
                                         :update_assignment,
                                         :destroy_assignment,
                                         :get_assignment_collection,
                                         :update_assignment_broadcast)
  end

  it "allows mentors to only view if not same user" do
    orgAdmin = build(:org_admin, organization_id: 1, id: 1)
    user = build(:mentor, organization_id: 1, id: 2)
    assignment = build(:assignment, organization_id: 1, user_id: orgAdmin.id)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly(:get_assignment,
                                         :get_assignment_collection)
  end

  it "allows all actions if same user" do
    user = build(:user, id: 1)
    assignment = build(:assignment, user_id: 1)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly(:get_assignment,
                                         :update_assignment,
                                         :destroy_assignment,
                                         :get_assignment_collection,
                                         :update_assignment_broadcast)
  end

  it "doesn't allow any action if student and not same user" do
    user = build(:student, id: 1)
    assignment = build(:assignment, user_id: 3)

    abilities = Ability.assignment_abilities(user, assignment)

    expect(abilities).to contain_exactly()
  end
end
