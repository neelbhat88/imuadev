class Api::V1::UserExpectationHistoryController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( userExpectationHistoryService = nil )
    @userExpectationHistoryService = userExpectationHistoryService ?
      userExpectationHistoryService : UserExpectationHistoryService.new
  end

  # GET /users/:id/user_expectation_history?expectation_id=#
  def get_user_expectation_history
    expectationId = params[:expectation_id]
    userId = params[:id]

    result = @userExpectationHistoryService.get_expectation_histories(userId, expectationId)

    render status: :ok,
      json: {
        info: "User Expectation History",
        expectation_history: result
      }
  end

end
