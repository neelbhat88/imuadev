require 'rails_helper'

describe Ability do

  it "doesn't allow any action if not in same organization" do
    user1 = build(:user, organization_id: 1)
    user2 = build(:user, organization_id: 2)

    abilities = Ability.user_abilities(user1, user2)

    expect(abilities).to contain_exactly()
  end

  it "actions allowed only on yourself" do
    user = build(:user)

    abilities = Ability.user_abilities(user, user)

    expect(abilities).to contain_exactly( :view_profile,
                                          :update_password,
                                          :edit_user_info,
                                          :read_user_tests,
                                          :manage_user_tests)
  end

  it "actions allowed to a super admin" do
    user = create(:super_admin)
    subject1 = create(:user)

    abilities = Ability.user_abilities(user, subject)
    expect(abilities).to contain_exactly( :view_profile,
                                          :delete_user,
                                          :edit_user_info,
                                          :change_semester,
                                          :read_user_tests,
                                          :manage_user_tests)
  end

  it "super admins can do all actions regardless of user's organizaiton" do
    user = create(:super_admin)
    subject2 = create(:user, organization_id: 11234)

    abilities = Ability.user_abilities(user, subject2)

    expect(abilities).to contain_exactly( :view_profile,
                                          :delete_user,
                                          :edit_user_info,
                                          :change_semester,
                                          :read_user_tests,
                                          :manage_user_tests)
  end

  it "actions allowed to a org admin" do
    user = create(:org_admin)
    subject = create(:user)

    abilities = Ability.user_abilities(user, subject)

    expect(abilities).to contain_exactly( :view_profile,
                                          :delete_user,
                                          :edit_user_info,
                                          :change_semester,
                                          :read_user_tests,
                                          :manage_user_tests)
  end

  it "org admins can't perform any actions on users not in organization" do
    user = create(:org_admin)
    subject = create(:user, organization_id: 1234)

    abilities = Ability.user_abilities(user, subject)

    expect(abilities).to contain_exactly( )
  end

  describe "actions allowed to a mentor" do
    it "if subject is not a student" do
      mentor = create(:mentor)
      subject = create(:org_admin)

      abilities = Ability.user_abilities(mentor, subject)

      expect(abilities).to contain_exactly( :view_profile )
    end

    it "if subject is an assigned student" do
      mentor = create(:mentor)
      subject = create(:student)
      create(:relationship, user_id: subject.id, assigned_to_id: mentor.id)

      abilities = Ability.user_abilities(mentor, subject)

      expect(abilities).to contain_exactly( :view_profile,
                                            :edit_user_info,
                                            :change_semester,
                                            :read_user_tests,
                                            :manage_user_tests)
    end

    it "if subject is not an assigned student" do
      mentor = create(:mentor)
      subject = create(:student)

      abilities = Ability.user_abilities(mentor, subject)

      expect(abilities).to contain_exactly()
    end

  end

  describe "actions allowed to a student" do
    it "if subject is an assigned mentor" do
      student = create(:student)
      subject = create(:mentor)
      create(:relationship, user_id: student.id, assigned_to_id: subject.id)

      abilities = Ability.user_abilities(student, subject)

      expect(abilities).to contain_exactly( :view_profile )
    end

    it "if subject is anyone but an assigned mentor" do
      student = create(:student)
      subject1 = create(:student)
      subject2 = create(:mentor)
      subject3 = create(:org_admin)

      expect(Ability.user_abilities(student, subject1)).to contain_exactly( )
      expect(Ability.user_abilities(student, subject2)).to contain_exactly( )
      expect(Ability.user_abilities(student, subject3)).to contain_exactly( )

    end
  end

end
