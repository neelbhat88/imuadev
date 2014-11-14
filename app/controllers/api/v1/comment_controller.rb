class Api::V1::CommentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( commentService = nil )
    @commentService = commentService ? commentService : CommentService.new(current_user)
  end

  # For handling comment creation logic within routes.rb
  # POST /comment/
  # Adds a comment for the given target_table, on behalf of current_user
  # def create
  #   Rails.logger.debug("****** params: #{params.inspect} ********")
  #   service_params = params.except(*[:controller, :action]).symbolize_keys
  #   service_params[:target_object] = params[:target_table].where(id: service_params[:id]).first
  #
  #   # if !can?(current_user, :create_comment, service_params[:target_object])
  #   #   render status: :forbidden, json: {}
  #   #   return
  #   # end
  #
  #   result = @commentService.create(service_params)
  #
  #   render status: result.status,
  #     json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  # end

end
