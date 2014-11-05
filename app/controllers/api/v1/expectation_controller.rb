class Api::V1::ExpectationController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( expectationService = nil, userExpectationHistoryService = nil )
    @expectationService = expectationService ? expectationService : ExpectationService.new
    @userExpectationHistoryService = userExpectationHistoryService ?
      userExpectationHistoryService : UserExpectationHistoryService.new
  end

  # GET /expectation/:id/status
  # Returns the status for all students for this expectation
  def get_expectation_status
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:expectation_id] = params[:id]

    # if !can?(current_user, :get_expectation_status, Expectation.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @expectationService.get_expectation_status(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  #####################################
  ########### ORGANIZATION ############
  #####################################

  # GET /organization/:id/expectations
  # Returns all Expectations for the given Organization
  def get_expectations
    orgId = params[:id]

    result = @expectationService.get_expectations(orgId)

    render status: :ok,
      json: {
        info: "expectations",
        expectations: result
      }
  end

  # POST /organization/:id/expectations
  # Creates an Expectation for the given Organization
  def create_expectation
    orgId       = params[:id].to_i
    expectation = params[:expectation]

    expectation["organization_id"] = orgId

    result = @expectationService.create_expectation(expectation)

    render status: result.status,
      json: {
        info: result.info,
        expectation: result.object
      }
  end

  # PUT /organization/:id/expectations/:expectation_id
  # Updates an Expectation for the given Organization
  def update_expectation
    orgId         = params[:id].to_i
    expectationId = params[:expectation_id].to_i
    expectation   = params[:expectation]

    expectation["organization_id"] = orgId
    expectation["id"]              = expectationId

    result = @expectationService.update_expectation(expectation)

    render status: result.status,
      json: {
        info: result.info,
        expectation: result.object
      }
  end

  # DELETE /organization/:id/expectations/:expectation_id
  # Deletes an Expectation for the given Organization
  def delete_expectation
    orgId         = params[:id].to_i
    expectationId = params[:expectation_id].to_i

    expectation = Expectation.new()
    expectation["organization_id"] = orgId
    expectation["id"]              = expectationId

    result = @expectationService.delete_expectation(expectation)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
