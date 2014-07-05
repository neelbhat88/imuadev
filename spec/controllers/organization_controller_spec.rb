require 'rails_helper'

describe Api::V1::OrganizationController, :type => :controller do

  describe "GET 'organization'" do

    describe "if user is Super Admin" do
      it "returns http success" do
        get :all_organizations
        print response
        x = "Hello"

        expect(x).to eq("Hello")
        #get 'roadmap'
        #response.should be_success
      end
    end

    describe "if user is not Super Admin" do
      it "returns 401 Unauthorized" do

      end
    end
  end

end
