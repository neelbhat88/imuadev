class Api::V1::UserTagController < ApplicationController
  respond_to :json

  before_filter :load_services

  def load_services( userRepo = nil, tagService = nil )
    @userRepository = userRepo ? userRepo : UserRepository.new
    @tagService = tagService ? tagService : TagService.new
  end

  def index
    userId = params[:user_id].to_i

    result = @tagService.get_user_tags(userId)

    render status: result.status,
      json: {
        info: result.info,
        tags: result.object
      }
  end

  def create
    userId = params[:user_id].to_i
    tag = params[:tag]

    result = @tagService.create_user_tag(userId, tag)

    render status: result.status,
      json: {
        info: result.info,
        tags: result.object
      }
  end

  def destroy
    userId = params[:id].to_i
    tag = params[:tag]

    result = @tagService.remove_user_tag(userId, tag)

    render status: result.status,
      json: {
        info: result.info,
        tags: result.object
      }
  end

end
