require 'rails_helper'

describe Ability do
  it "allows all actions to a super admin" do
    org = create(:organization)
    expectation = create(:expectation, organization_id: org.id)
    user = build(:super_admin)

    abilities = Ability.expectation_abilities(user, expectation)

    expect(abilities).to contain_exactly(:get_expectation_status,
                                         :put_expectation_status)
  end

  it "doesn't allow any action if not in same organization" do
    org = create(:organization)
    expectation = create(:expectation, organization_id: org.id)
    user = build(:user, organization_id: org.id + 1)

    abilities = Ability.expectation_abilities(user, expectation)

    expect(abilities).to contain_exactly()
  end

  it "allows org admin actions" do
    org = create(:organization)
    expectation = create(:expectation, organization_id: org.id)
    user = build(:org_admin, organization_id: org.id)

    abilities = Ability.expectation_abilities(user, expectation)

    expect(abilities).to contain_exactly(:get_expectation_status,
                                         :put_expectation_status)
  end

  it "allows mentor actions" do
    org = create(:organization)
    expectation = create(:expectation, organization_id: org.id)
    user = build(:mentor, organization_id: org.id)

    abilities = Ability.expectation_abilities(user, expectation)

    expect(abilities).to contain_exactly(:get_expectation_status,
                                         :put_expectation_status)
  end

  it "allows student actions" do
    org = create(:organization)
    expectation = create(:expectation, organization_id: org.id)
    user = build(:student, organization_id: org.id)

    abilities = Ability.expectation_abilities(user, expectation)

    expect(abilities).to contain_exactly()
  end

end
