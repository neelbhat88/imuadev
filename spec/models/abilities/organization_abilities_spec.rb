require 'rails_helper'

describe Ability do
  it "allows all actions to a super admin" do
    user = build(:super_admin)
    org = build(:organization)

    abilities = Ability.organization_abilities(user, org)

    expect(abilities).to contain_exactly(:create_user)
  end

  it "doesn't allow any action if not in same organization" do
    user = build(:user, organization_id: 1)
    org = build(:organization, id: 3)

    abilities = Ability.organization_abilities(user, org)

    expect(abilities).to contain_exactly()
  end

  it "allows org admin actions" do
    user = build(:org_admin, organization_id: 1)
    org = build(:organization, id: 1)

    abilities = Ability.organization_abilities(user, org)

    expect(abilities).to contain_exactly(:create_user)
  end

  it "allows mentor actions" do
    user = build(:mentor, organization_id: 1)
    org = build(:organization, id: 1)

    abilities = Ability.organization_abilities(user, org)

    expect(abilities).to contain_exactly()
  end

  it "allows student actions" do
    user = build(:student, organization_id: 1)
    org = build(:organization, id: 1)

    abilities = Ability.organization_abilities(user, org)

    expect(abilities).to contain_exactly()
  end
end
