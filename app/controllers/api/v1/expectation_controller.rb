class Api::V1::ExpectationController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( expectationService = nil )
    @expectationService = expectationService ? expectationService : ExpectationService.new
  end

  #####################################
  ########### ORGANIZATION ############
  #####################################

  # GET /organization/:id/expectations
  # Returns all Expectations for the given Organization
  def get_expectations
    orgId = params[:id]

    result = @expectationService.get_expectations(orgId)

    render status: result.status,
      json: {
        info: result.info,
        modules_progress: result.object
      }
  end

  # POST /organization/:id/expectations
  # Creates an Expectation for the given Organization
  def create_expectation
    orgId       = params[:id]
    expectation = params[:expectation]

    expectation[:organization_id] = orgId

    result = @expectationService.create_expectation(expectation)

    viewExpectation = ViewExpectation.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        expectation: viewExpectation
      }
  end

  # PUT /organization/:id/expectations/:expectation_id
  # Updates an Expectation for the given Organization
  def update_expectation
    orgId         = params[:id]
    expectationId = params[:expectation_id]
    expectation   = params[:expectation]

    expectation[:organization_id] = orgId
    expectation[:id]              = expectationId

    # TODO Check that the given orgId matches to the Expectation

    result = @expectationService.update_expectation(expectation)

    viewExpectation = ViewExpectation.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        expectation: viewExpectation
      }
  end

  # DELETE /organization/:id/expectations/:expectation_id
  # Deletes an Expectation for the given Organization
  def delete_expectation
    orgId         = params[:id]
    expectationId = params[:expectation_id]

    # TODO Check that the given orgId matches to the Expectation

    result = @expectationService.delete_expectation(expectationId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  #################################
  ############# USER ##############
  #################################

  # GET /user/:id/expectations
  # Returns all UserExpectations for the given User
  def get_user_expectations
    userId = params[:id]

    result = @expectationService.get_user_expectations(userId)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # POST /user/:id/expectations
  # Creates a UserExpectation for the given User
  def create_user_expectation
    userId          = params[:id]
    userExpectation = params[:userExpectation]

    userExpectation[:user_id] = userId

    result = @expectationService.create_user_expectation(userExpectation)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # PUT /user/:id/expectations/:expectation_id
  # Updates a UserExpectation for the given User
  def update_user_expectation
    userId            = params[:id]
    userExpectationId = params[:expectation_id]
    userExpectation   = params[:userExpectation]

    userExpectation[:user_id] = userId
    userExpectation[:id]      = userExpectationId

    # TODO Check that the given userId matches to the userExpectation

    result = @expectationService.update_user_expectation(userExpectation)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # DELETE /user/:id/expectations/:expectation_id
  # Deletes a UserExpectation for the given Uswe
  def delete_user_expectation
    userId            = params[:id]
    userExpectationId = params[:expectation_id]

    # TODO Check that the given userId matches to the userExpectation

    result = @expectationService.delete_user_expectation(userExpectationId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

end
