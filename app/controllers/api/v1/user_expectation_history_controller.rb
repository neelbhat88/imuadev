class Api::V1::UserExpectationHistoryController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( expectationService = nil )
    @userExpectationHistoryService = userExpectationHistoryService ?
      userExpectationHistoryService : UserExpectationHistoryService.new
  end

  # GET /users/:user_id/user_expectation_history/:user_expectation_id
  def get_user_expectation_history
    userExpectationId = params[:user_expectation_id]
    userId = params[:user_id]

    result = @userExpectationHistoryService.get_expectation_histories(userId, userExpectationId)

    render status: :ok,
      json: {
        info: "User Expectation History",
        expectations: result
      }
  end

end
