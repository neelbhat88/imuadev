class Api::V1::UserGpaController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( userRepo=nil, userClassHistoryService=nil,
                     userGpaService=nil )
    @userRepository = userRepo ? userRepo : UserRepository.new
    @userGpaService = userGpaService ? userGpaService : UserGpaService.new
      UserGpaHistoryService.new
  end

  # POST /users/:user_id/user_gpa
  def create
    userId = params[:user_id]
    user_gpa = params[:user_gpa]
    time_unit_id = user_gpa[:time_unit_id]
    new_gpa = user_gpa[:value]

    user = @userRepository.get_user(userId)

    if !can?(current_user, :gpa_override, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @userGpaService.create_override_gpa(userId, time_unit_id, new_gpa)

    render status: result.status,
      json: {
        info: result.info,
        user_gpa: result.object
      }
  end

end
