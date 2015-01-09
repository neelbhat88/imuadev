require 'rails_helper'

describe Ability do
  it "allows all actions to a super admin" do
    user = build(:super_admin)
    subjectUser = create(:user)
    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(user, user_assignment)

    expect(abilities).to contain_exactly(:update_user_assignment,
                                         :destroy_user_assignment,
                                         :get_user_assignment_collection,
                                         :index_comments,
                                         :create_comment)
  end

  it "doesn't allow any action if not in same organization" do
    user = build(:user, organization_id: 1)
    subjectUser = create(:user, organization_id: 3)
    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(user, user_assignment)

    expect(abilities).to contain_exactly()
  end

  it "allows org admin actions" do
    user = build(:org_admin, organization_id: 1)
    subjectUser = create(:student, organization_id: 1)
    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(user, user_assignment)

    expect(abilities).to contain_exactly(:update_user_assignment,
                                         :destroy_user_assignment,
                                         :get_user_assignment_collection,
                                         :index_comments,
                                         :create_comment)
  end

  it "allows mentors all actions if related" do
    mentor = create(:mentor)
    subjectUser = create(:student)
    create(:relationship, user_id: subjectUser.id, assigned_to_id: mentor.id)

    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(mentor, user_assignment)

    expect(abilities).to contain_exactly(:update_user_assignment,
                                         :destroy_user_assignment,
                                         :get_user_assignment_collection,
                                         :index_comments,
                                         :create_comment)
  end

  it "allows mentors to only view if not related" do
    mentor = create(:mentor)
    subjectUser = create(:student)

    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(mentor, user_assignment)

    expect(abilities).to contain_exactly(:get_user_assignment_collection)
  end

  it "allows all actions, except destroy, if same user" do
    subjectUser = create(:user)
    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(subjectUser, user_assignment)

    expect(abilities).to contain_exactly(:update_user_assignment,
                                         :get_user_assignment_collection,
                                         :index_comments,
                                         :create_comment)
  end

  it "doesn't allow any action if student is not same user" do
    user = build(:student, id: 1)
    subjectUser = create(:student, id: 3)
    user_assignment = build(:user_assignment, user_id: subjectUser.id)

    abilities = Ability.user_assignment_abilities(user, user_assignment)

    expect(abilities).to contain_exactly()
  end
end
