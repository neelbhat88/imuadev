require 'rails_helper'

describe User do
  it "is valid with a email and password" do
    user = User.new(email: 'email@gmail.com', password: "password")

    expect(user).to be_valid
  end

  it "is invalid without a email" do
    expect(User.new(email: nil, password: "password")).to have(1).errors_on(:email)
  end

  it "is invalid without a password" do
    expect(User.new(password: nil, email: "email@email.com")).to have(1).errors_on(:password)
  end

  it "is invalid with a duplicate email address" do
    user = create(:user)

    newuser = User.new(email: user.email, password: "password")

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
