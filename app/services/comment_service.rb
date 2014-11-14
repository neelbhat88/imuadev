class CommentService

  def initialize(current_user)
    @current_user = current_user
  end

  # Adds the :comment to the given :target_table/:id, on behalf of current_user
  def create(params)
    commentable_object = params[:target_table].where(id: params[:id]).first

    # if !can?(@current_user, :create_comment, commentable_object)
    #   render status: :forbidden, json: {}
    #   return
    # end

    comment = commentable_object.comments.create
    comment.comment = params[:comment]
    comment.user_id = @current_user.id

    if comment.save
      ret = comment.attributes
      return ReturnObject.new(:ok, "Successfully added comment id #{comment.id} to #{commentable_object.class.name} id #{commentable_object.id}.", ret)
    else
      return ReturnObject.new(:internal_server_error, "Failed to add comment to #{commentable_object.class.name} id #{commentable_object.id}.", nil)
    end
  end

end
