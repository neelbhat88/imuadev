class Api::V1::AnswersController < ApplicationController

  #skip_before_filter :authenticate_token

  respond_to :json

  def index
    render status: 200,
      json: {
        answers: Answers.order(:qnum).all
      }

  end
end
