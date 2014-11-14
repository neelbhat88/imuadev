class Api::V1::CommentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( commentService = nil )
    @commentService = commentService ? commentService : CommentService.new(current_user)
  end

end
