class CommentService

  def initialize(current_user)
    @current_user = current_user
  end

  # Adds the :comment to the given :target_table/:commentable_id, on behalf of current_user
  def create(params)
    conditions = Marshal.load(Marshal.dump(params))
    commentable_object = params[:target_table].where(id: conditions[:commentable_id]).first

    # if !can?(@current_user, :create_comment, commentable_object)
    #   render status: :forbidden, json: {}
    #   return
    # end

    comment = commentable_object.comments.create
    comment.comment = params[:comment]
    comment.user_id = @current_user.id

    if comment.save
      commentQ = Querier.new(Comment).select([:id, :comment, :user_id, :created_at, :updated_at]).where(conditions.except(:comment))
      conditions[:user_id] = commentQ.pluck(:user_id)
      userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
      userQ.set_subQueriers([commentQ])

      view = { users: userQ.view }

      return ReturnObject.new(:ok, "Successfully added comment id #{comment.id} to #{commentable_object.class.name} id #{commentable_object.id}.", view)
    else
      return ReturnObject.new(:internal_server_error, "Failed to add comment to #{commentable_object.class.name} id #{commentable_object.id}.", nil)
    end
  end

  def index(params)
    conditions = Marshal.load(Marshal.dump(params))
    commentable_object = conditions[:target_table].where(id: conditions[:commentable_id]).first

    # if !can?(@current_user, :index_comments, commentable_object)
    #   render status: :forbidden, json: {}
    #   return
    # end

    commentQ = Querier.new(Comment).select([:id, :comment, :user_id, :created_at, :updated_at]).where(conditions)
    conditions[:user_id] = commentQ.pluck(:user_id)
    userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([commentQ])

    view = { users: userQ.view }

    return ReturnObject.new(:ok, "Comments for #{commentable_object.class.name} id #{commentable_object.id}.", view)
  end

end
