class Api::V1::UserTagController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( userRepo = nil, tagService = nil )
    @userRepository = userRepo ? userRepo : UserRepository.new
    @tagService = tagService ? tagService : TagService.new
  end

  def index
    userId = params[:id].to_i

    result = @tagService.get_user_tags(userId)

    render status: result.status
      json: {
        info: result.info,
        tags: result.object
      }
  end

  def create
  end

  def destroy
  end

end
