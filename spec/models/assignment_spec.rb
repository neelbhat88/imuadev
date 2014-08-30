require 'rails_helper'

describe Assignment do
  describe "is invalid" do
    it "without user_id" do
      expect(Assignment.new(user_id: nil)).to have(1).errors_on(:user_id)
    end

    it "without title" do
      expect(Assignment.new(title: nil)).to have(1).errors_on(:title)
    end

    it "without description" do
      expect(Assignment.new(description: nil)).to have(0).errors_on(:description)
    end

    it "without due_datetime" do
      expect(Assignment.new(due_datetime: nil)).to have(0).errors_on(:due_datetime)
    end
  end
end
