class Api::V1::UserClassController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_filter :load_services

  def load_services( userClassService=nil, userRepo=nil, userClassHistoryService=nil,
                     userGpaService=nil, userGpaHistoryService=nil )
    @userClassService = userClassService ? userClassService : UserClassService.new
    @userRepository = userRepo ? userRepo : UserRepository.new
    @userClassHistoryService = userClassHistoryService ? userClassHistoryService : UserClassHistoryService.new
    @userGpaService = userGpaService ? userGpaService : UserGpaService.new
    @userGpaHistoryService = userGpaHistoryService ? userGpaHistoryService :
      UserGpaHistoryService.new
  end

  # POST /users/:user_id/user_gpa
  def create
    userId = params[:user_id]
    new_gpa = params[:user_gpa]

    result = @userGpaService.create_override_gpa(current_user, userId, new_gpa)

    render status: result.status,
      json: {
        info: result.info,
        user_gpa: result.object
      }
  end

end
