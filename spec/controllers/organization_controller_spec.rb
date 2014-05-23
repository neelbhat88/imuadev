require 'spec_helper'

describe OrganizationController do

  describe "GET 'roadmap'" do
    it "returns http success" do
      get 'roadmap'
      response.should be_success
    end
  end

end
