class Api::V1::TestController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( testService = nil )
    @testService = testService ? testService : TestService.new
  end

  #####################################
  ########### ORGANIZATION ############
  #####################################

  # GET /organization/:id/tests
  # Returns all OrgTests for the given Organization
  def get_org_tests
    orgId = params[:id].to_i

    organization = OrganizationRepository.new.get_organization(orgId)
    if !can?(current_user, :read_org_tests, organization)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.get_org_tests(orgId)

    render status: :ok,
      json: {
        info: "orgTests",
        orgTests: result
      }
  end

  # POST /org_test
  # Creates an OrgTest
  def create_org_test
    orgTest = params[:orgTest]

    organization = OrganizationRepository.new.get_organization(orgId)
    if !can?(current_user, :create_org_test, organization)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.create_org_test(orgTest)

    render status: result.status,
      json: {
        info: result.info,
        expectation: result.object
      }
  end

  # PUT /org_test/:id
  # Updates an OrgTest
  def update_org_test
    orgTestId      = params[:id].to_i
    updatedOrgTest = params[:org_test]

    orgTest = @test_service.get_org_test(orgTestId)
    if !can?(current_user, :update_org_test, orgTest)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.update_org_test(orgTestId, updatedOrgTest)

    render status: result.status,
      json: {
        info: result.info,
        expectation: result.object
      }
  end

  # DELETE /org_test/:id
  # Deletes an OrgTest for the given Organization
  def delete_org_test
    orgTestId = params[:id].to_i

    orgTest = @test_service.get_org_test(orgTestId)
    if !can?(current_user, :delete_org_test, orgTest)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.delete_org_test(orgTestId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  #################################
  ############# USER ##############
  #################################

  # GET /users/:id/tests?time_unit_id=#
  # Returns all UserTests for the User's given time_unit_id.
  # If time_unit_id is -1, then returns all UserTests for the User.
  def get_user_tests
    userId     = params[:id].to_i
    timeUnitId = params[:time_unit_id].to_i

    user = UserRepository.new.get_user(userId)
    if !can?(current_user, :read_user_tests, user)
      render status: :forbidden,
        json: {}
      return
    end

    info = (timeUnitId == -1) ? "all user_tests" : "user_tests for time_unit"
    result = (timeUnitId == -1) ?
             @testService.get_user_tests(userId) :
             @testService.get_user_tests_time_unit(userId, timeUnitId)

    render status: :ok,
      json: {
        info: info,
        user_tests: result
      }
  end

  # POST /user_test
  # Creates a UserTest
  def create_user_test
    userTest   = params[:userTest]

    user = UserRepository.new.get_user(userId)
    if !can?(current_user, :create_user_test, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.create_user_test(userTest)

    render status: result.status,
      json: {
        info: result.info,
        user_test: result.object
      }
  end

  # PUT /user_test/:id
  # Updates a UserTest
  def update_user_test
    userTestId = params[:id].to_i
    userTest   = params[:userTest]

    user = UserRepository.new.get_user(userId)
    if !can?(current_user, :update_user_test, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.update_user_test(userTestId, userTest)

    render status: result.status,
      json: {
        info: result.info,
        user_test: result.object
      }
  end

  # DELETE /user_test/:id
  # Deletes a UserTest
  def delete_user_test
    userTestId = params[:id].to_i

    user = UserRepository.new.get_user(userId)
    if !can?(current_user, :delete_user_test, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @testService.delete_user_test(userTestId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

end
