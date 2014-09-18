class Api::V1::UserExpectationController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  # GET /users/:user_id/user_expectation
  def index
    userId = params[:user_id]

    result = UserExpectationService.new.get_and_create_user_expectations(userId)

    render status: :ok,
      json: {
        info: "user_expectations",
        user_expectations: result
      }
  end

  # GET /user_expectation/:id
  def show
    user_expectation_id = params[:id]

    user_expectation = UserExpectationService.new.get_user_expectation(user_expectation_id)

    render status: :ok,
      json:  {
        info: "User Expectation",
        user_expectation: user_expectation
      }
  end

  # PUT /user_expectation/:id
  def update
    user_expectation_id   = params[:id].to_i
    userExpectation = params[:userExpectation]

    result = UserExpectationService.new.update_user_expectation(user_expectation_id, userExpectation, current_user)

    render status: result.status,
      json: {
        info: result.info,
        user_expectation: result.object
      }
  end

  # GET /user_expectation/:id/history
  def history
    user_expectation_id = params[:id].to_i

    history = UserExpectationHistoryService.new.get_user_expectation_history(user_expectation_id)

    render status: :ok,
      json: {
        info: "History for expectation id: #{user_expectation_id}",
        user_expectation_history: history
      }
  end
end
