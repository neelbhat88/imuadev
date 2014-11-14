class CommentService

  def initialize(current_user)
    @current_user = current_user
  end

  # Assumes target_object has already been pulled from DB, due to authorizations
  def create(params)
    comment = params[:target_object].comments.create
    comment.comment = params[:comment]
    comment.user_id = @current_user.id
    if comment.save
      ret = comment.attributes
      return ReturnObject.new(:ok, "Successfully added comment #{comment.id} to #{params[:target_object].class.name} id #{params[:target_object].id}.", ret)
    else
      return ReturnObject.new(:internal_server_error, "Failed to add comment to #{params[:target_object].class.name} id #{params[:target_object].id}.", nil)
    end
  end

end
