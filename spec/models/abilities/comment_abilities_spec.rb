require 'rails_helper'

describe Ability do
  it "allows all actions to a super admin" do
    user = build(:super_admin)
    subjectUser = create(:user)
    comment = build(:comment, user_id: subjectUser.id)

    abilities = Ability.comment_abilities(user, comment)

    expect(abilities).to contain_exactly(:update_comment,
                                         :destroy_comment)
  end

  it "doesn't allow any action if not in same organization" do
    user = build(:user, organization_id: 1)
    subjectUser = create(:user, organization_id: 3)
    comment = build(:comment, user_id: subjectUser.id)

    abilities = Ability.comment_abilities(user, comment)

    expect(abilities).to contain_exactly()
  end

  it "allows no actions if different user" do
    user = build(:org_admin, organization_id: 1)
    subjectUser = create(:student, organization_id: 1)
    comment = build(:comment, user_id: subjectUser.id)

    abilities = Ability.comment_abilities(user, comment)

    expect(abilities).to contain_exactly()
  end

  it "allows all actions if same user" do
    subjectUser = create(:user)
    comment = build(:comment, user_id: subjectUser.id)

    abilities = Ability.comment_abilities(subjectUser, comment)

    expect(abilities).to contain_exactly(:update_comment,
                                         :destroy_comment)
  end

end
