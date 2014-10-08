require 'rails_helper'

describe User do
  it "is valid" do
    user = build(:student)

    expect(user).to be_valid
  end

  it "is invalid without a email" do
    user = build(:student, email: nil)
    expect(user).to have(1).errors_on(:email)
  end

  it "is invalid without a password" do
    user = build(:student, password: nil)
    expect(user).to have(1).errors_on(:password)
  end

  it "is invalid without a first name" do
    user = build(:student, first_name: nil)
    expect(user).to have(1).errors_on(:first_name)
  end

  it "is invalid without a last name" do
    user = build(:student, last_name: nil)
    expect(user).to have(1).errors_on(:last_name)
  end

  it "is invalid without a role" do
    user = build(:student, role: nil)
    expect(user).to have(1).errors_on(:role)
  end

  it "is invalid without a organization id" do
    user = build(:student, organization_id: nil)
    expect(user).to have(1).errors_on(:organization_id)
  end

  it "is invalid with a duplicate email address" do
    user = create(:user)

    newuser = build(:user, email: user.email)

    expect(newuser).to have(1).errors_on(:email)
  end

  describe "student?" do
    it "returns true" do
      user = build(:student)

      expect(user.student?).to be true
    end

    it "returns false" do
      user = build(:mentor)

      expect(user.student?).to be false
    end
  end

  describe "mentor?" do
    it "returns true" do
      user = build(:mentor)

      expect(user.mentor?).to be true
    end

    it "returns false" do
      user = build(:student)

      expect(user.mentor?).to be false
    end
  end

  describe "org_admin?" do
    it "returns true" do
      user = build(:org_admin)

      expect(user.org_admin?).to be true
    end

    it "returns false" do
      user = build(:mentor)

      expect(user.org_admin?).to be false
    end
  end

  describe "super_admin?" do
    it "returns true" do
      user = build(:super_admin)

      expect(user.super_admin?).to be true
    end

    it "returns false" do
      user = build(:mentor)

      expect(user.super_admin?).to be false
    end
  end
end
