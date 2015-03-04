class Api::V1::GraphController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( gpaService = nil )
    @gpaService = gpaService ? gpaService : UserGpaService.new
  end

  def gpa
    user_ids = params[:user_ids].map{|i| i.to_i}
    time_unit_ids = params[:time_unit_ids].map{|i| i.to_i}

    # ToDo
    # if !can?(current_user, :get_history, userIds)
    #   render status: :forbidden, json: {}
    #   return
    # end

    gpas = @gpaService.get_users_gpas(user_ids, time_unit_ids)
    # ToDo - if more than 1 user make sure the history
    #     is averaged for all users for each semester

    render status: :ok,
      json: { gpas: gpas }
  end
end
