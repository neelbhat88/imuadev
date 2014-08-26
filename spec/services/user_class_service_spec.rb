require 'rails_helper'

describe UserClassService do

  describe "user_gpa" do
    it "correctly calculates user gpa for a time_unit" do
      userId = 1
      time_unit_id = 1
      create(:user_class, gpa: 4.0, credit_hours: 1, user_id: userId, time_unit_id: time_unit_id)
      create(:user_class, gpa: 3.33, credit_hours: 0.5, user_id: userId, time_unit_id: time_unit_id)
      create(:user_class, gpa: 2.67, credit_hours: 3, user_id: userId, time_unit_id: time_unit_id)
      create(:user_class, gpa: 3.0, credit_hours: 2, user_id: userId, time_unit_id: time_unit_id)
      # Other user - should not include this in calculation
      create(:user_class, gpa: 3.0, credit_hours: 2, user_id: 3, time_unit_id: 1)

      gpa = UserClassService.new.user_gpa(userId, time_unit_id)

      expect(gpa).to eq(3.03)
    end

    it "correctly calculates user gpa across all semesters" do
      userId = 1
      create(:user_class, gpa: 4.0, credit_hours: 1, user_id: userId, time_unit_id: 1)
      create(:user_class, gpa: 3.33, credit_hours: 0.5, user_id: userId, time_unit_id: 2)
      create(:user_class, gpa: 2.67, credit_hours: 3, user_id: userId, time_unit_id: 3)
      create(:user_class, gpa: 3.0, credit_hours: 2, user_id: userId, time_unit_id: 4)
      # Other user - should not include this in calculation
      create(:user_class, gpa: 3.0, credit_hours: 2, user_id: 3, time_unit_id: 1)

      gpa = UserClassService.new.user_gpa(userId, 0)

      expect(gpa).to eq(3.03)
    end
  end

end
