module ControllerMacros
  def login_org_admin
    before(:each) do
      create(:app_version)

      @request.env["devise.mapping"] = Devise.mappings[:org_admin]
      @org_admin = create(:org_admin) # Using factory girl as an example
      sign_in :user, @org_admin

      token = create(:access_token, user_id: @org_admin.id)

      @request.env["X-API-TOKEN"] = token.token_value
      @request.env["X-API-EMAIL"] = @org_admin.email
    end
  end

  def login_student
    before(:each) do
      create(:app_version)

      @request.env["devise.mapping"] = Devise.mappings[:student]
      @student = create(:student) # Using factory girl as an example
      sign_in :user, @student

      token = create(:access_token, user_id: @student.id)

      @request.env["X-API-TOKEN"] = token.token_value
      @request.env["X-API-EMAIL"] = @student.email
    end
  end

  def login_mentor
    before(:each) do
      create(:app_version)

      @request.env["devise.mapping"] = Devise.mappings[:mentor]
      @mentor = create(:mentor) # Using factory girl as an example
      sign_in :user, @mentor

      token = create(:access_token, user_id: @mentor.id)

      @request.env["X-API-TOKEN"] = token.token_value
      @request.env["X-API-EMAIL"] = @mentor.email
    end
  end

  def login_super_admin
    before(:each) do
      create(:app_version)

      @request.env["devise.mapping"] = Devise.mappings[:super_admin]
      @super_admin = create(:super_admin) # Using factory girl as an example
      sign_in :user, @super_admin

      token = create(:access_token, user_id: @super_admin.id)

      @request.env["X-API-TOKEN"] = token.token_value
      @request.env["X-API-EMAIL"] = @super_admin.email
    end
  end

end
