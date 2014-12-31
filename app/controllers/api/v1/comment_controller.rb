class Api::V1::CommentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( commentService = nil )
    @commentService = commentService ? commentService : CommentService.new(current_user)
  end

  def update
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:comment_id] = params[:id]

    comment = Comment.where(id: service_params[:comment_id]).first
    if !can?(@current_user, :update_comment, comment)
      render status: :forbidden, json: {}
      return
    end

    result = @commentService.update(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  def destroy
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:comment_id] = params[:id]

    comment = Comment.where(id: service_params[:comment_id]).first
    if !can?(@current_user, :destroy_comment, comment)
      render status: :forbidden, json: {}
      return
    end

    result = @commentService.destroy(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

end
