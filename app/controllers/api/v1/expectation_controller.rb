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
  # Returns all Expectations for the given organization
  def expectations
    orgId = params[:id]

    result = @expectationService.get_expectations(orgId)

    render status: result.status,
      json: {
        info: result.info,
        modules_progress: result.object
      }
  end

  # POST /expectation
  # Creates an Expectation
  def create_expectation
    expectation = params[:expectation]

    result = @expectationService.create_expectation(expectation)

    viewExpectation = ViewExpectation.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        expectation: viewExpectation
      }
  end

  # PUT /expectation/:id
  # Updates an Expectation
  def update_expectation
    expectationId = params[:id]
    expectation   = params[:expectation]

    expectation[:id] = expectationId

    result = @expectationService.update_expectation(expectation)

    viewExpectation = ViewExpectation.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        expectation: viewExpectation
      }
  end

  # DELETE /expectation/:id
  # Deletes an Expectation
  def delete_expectation
    expectationId = params[:expectation_id]

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
  # Returns all UserExpectations for a given user
  def user_expectations
    userId = params[:id]

    result = @expectationService.get_user_expectations(userId)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # POST /user_expectation
  # Creates a UserExpectation
  def create_user_expectation
    expectation = params[:expectation]

    result = @expectationService.create_user_expectation(userExpectation)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # PUT /user_expectation/:id
  # Updates a UserExpectation
  def update_user_expectation
    userExpectationId = params[:id]
    userExpectation   = params[:expectation]

    userExpectation[:id] = userExpectationId

    result = @expectationService.update_user_expectation(userExpectation)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # DELETE /user_expectation/:id
  # Deletes a UserExpectation
  def delete_user_expectation
    userExpectationId = params[:id]

    result = @expectationService.delete_user_expectation(userExpectationId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

end
