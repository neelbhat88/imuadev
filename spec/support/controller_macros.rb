module ControllerMacros
  def login_org_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:org_admin]
      org_admin = create(:org_admin) # Using factory girl as an example
      sign_in :user, org_admin
    end
  end

  def login_student
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:student]
      student = create(:student) # Using factory girl as an example
      sign_in :user, student
    end
  end

  def login_mentor
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:mentor]
      mentor = create(:mentor) # Using factory girl as an example
      sign_in :user, mentor
    end
  end

  def login_super_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:super_admin]
      super_admin = create(:super_admin) # Using factory girl as an example
      sign_in :user, super_admin
    end
  end
end
