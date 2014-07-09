require 'rails_helper'

describe Api::V1::ProgressController do
  before(:each) do
    @progressService = instance_double("ProgressService")
    @milestoneService = instance_double("MilestoneService")
    @userClassService = instance_double("UserClassService")
    @userRepository = instance_double("UserRepository")
    controller.load_services(@progressService, @milestoneService, @userClassService, @userRepository)
  end

  describe "GET #user_classes" do
    context "as a student" do
      login_student

      let(:userId) { subject.current_user.id }
      let(:time_unit_id) { subject.current_user.time_unit_id }
      let(:org_id) { subject.current_user.organization_id }

      it "returns 200 with user_classes" do
        # ToDo: Doesn't work with expect -- why!!!
        user = User.new do |u|
          u.id = 1
          u.organization_id = org_id
        end
        allow(@userRepository).to receive(:get_user).and_return(user)
        allow(@userClassService).to receive(:get_user_classes).with(userId, time_unit_id)
          .and_return(ReturnObject.new(:ok, "User Classes in spec", nil))

        get :user_classes, {:id => userId, :org_id => org_id, :time_unit_id => time_unit_id}

        expect(response.status).to eq(200)
        expect(json).to have_key("user_classes")
      end

      xit "returns 403 if current_user is not in :org_id" do
        user = User.new do |u|
          u.id = 1
          u.organization_id = 12345
        end
        allow(@userRepository).to receive(:get_user).and_return(user)

        get :user_classes, {:id => userId, :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end

      it "returns 403 if :id is not current student" do
        subject.current_user.id = 1

        get :user_classes, {:id => '2', :time_unit_id => time_unit_id}

        expect(response.status).to eq(403)
      end
    end
  end

end
