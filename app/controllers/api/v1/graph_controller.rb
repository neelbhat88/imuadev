class Api::V1::GraphController < ApplicationController
  respond_to :json

  before_filter :load_services

  def load_services( gpaService = nil, gpaHistoryService = nil )
    @gpaService = gpaService ? gpaService : UserGpaService.new
    @gpaHistoryService = gpaHistoryService ? gpaHistoryService : UserGpaHistoryService.new
  end

  def gpa
    user_ids = params[:user_ids].map{|i| i.to_i}
    time_unit_ids = params[:time_unit_ids].map{|i| i.to_i}

    if !can?(current_user, :get_gpa_history, GpaHistoryAuthorization.new(user_ids))
      render status: :forbidden, json: {}
      return
    end

    if user_ids.length == 1 && time_unit_ids.length == 1
      gpas = @gpaHistoryService.get_user_gpa_history(user_ids[0], time_unit_ids[0], true)
    else
      gpas = @gpaService.get_users_gpas(user_ids, time_unit_ids)
      # ToDo - if more than 1 user make sure the history
      #     is averaged for all users for each semester
    end

    render status: :ok,
      json: { gpas: gpas }
  end
end
