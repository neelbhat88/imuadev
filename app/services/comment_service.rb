class CommentService

  def initialize(current_user)
    @current_user = current_user
  end

  # Adds the :comment to the given :target_table/:commentable_id, on behalf of current_user
  def create(params)
    conditions = Marshal.load(Marshal.dump(params))
    commentable_object = conditions[:target_table].where(id: conditions[:commentable_id]).first

    comment = commentable_object.comments.create
    comment.comment = params[:comment]
    comment.user_id = @current_user.id

    if comment.save
      ret = get_comments_view({ commentable_type: comment.commentable_type,
                                commentable_id: comment.commentable_id })

      send_comment_added_email(comment, @current_user)

      return ReturnObject.new(:ok, "Successfully added comment id #{comment.id} to #{commentable_object.class.name} id #{commentable_object.id}.", ret)
    else
      return ReturnObject.new(:internal_server_error, "Failed to add comment to #{commentable_object.class.name} id #{commentable_object.id}.", nil)
    end
  end

  def index(params)
    conditions = Marshal.load(Marshal.dump(params))
    commentable_object = conditions[:target_table].where(id: conditions[:commentable_id]).first

    ret = get_comments_view({ commentable_type: conditions[:target_table],
                              commentable_id: conditions[:commentable_id] })

    return ReturnObject.new(:ok, "Comments for #{commentable_object.class.name} id #{commentable_object.id}.", ret)
  end

  def update(params)
    conditions = Marshal.load(Marshal.dump(params))
    dbComment = Comment.where(id: conditions[:comment_id]).first

    if dbComment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Comment with id: #{conditions[:comment_id]}.", nil)
    end

    if dbComment.update_attributes(:comment => conditions[:comment])
      ret = get_comments_view({ commentable_type: dbComment.commentable_type,
                                commentable_id: dbComment.commentable_id })
      return ReturnObject.new(:ok, "Successfully updated Comment, id: #{dbComment.id}.", ret)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Comment, id: #{dbComment.id}.  Errors: #{dbComment.errors.inspect}.", nil)
    end
  end

  def destroy(params)
    conditions = Marshal.load(Marshal.dump(params))
    dbComment = Comment.where(id: conditions[:comment_id]).first

    if dbComment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Comment with id: #{conditions[:comment_id]}.", nil)
    end

    if dbComment.destroy()
      ret = get_comments_view({ commentable_type: dbComment.commentable_type,
                                commentable_id: dbComment.commentable_id })
      return ReturnObject.new(:ok, "Successfully deleted Comment, id: #{dbComment.id}.", ret)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Comment, id: #{dbComment.id}.  Errors: #{dbComment.errors.inspect}.", nil)
    end
  end



  # Helper methods - not to be called by controller
private
  # Returned by most CommentService methods so that the front view has an
  # up-to-date list of all the comments (in case one was since added/updated).
  # Needs 'commentable_type' and 'commentable_id' params.
  def get_comments_view(params)
    conditions = Marshal.load(Marshal.dump(params))

    commentQ = Querier.factory(Comment).select([:id, :comment, :user_id, :created_at, :updated_at]).where(conditions)
    conditions[:user_id] = commentQ.pluck(:user_id)
    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([commentQ])

    view = { users: userQ.view }

    return view
  end

  def send_comment_added_email(comment, current_user)
    return if assignment.assignment_owner_type != "User"
    assignment[:user_id] = assignment.assignment_owner_id

    Background.process do
      # Get list of all users who have commented on the item
      involved_users_ids = Comment.where(:commentable_id => comment.commentable_id,
                                         :commentable_type => comment.commentable_type)
                                  .pluck(:user_id).uniq

      # ToDo: Duck type this biatch!!! There is a better way to do this, but doing
      #  it like this for now so we can get comments into Production quickly.
      if comment.commentable_type == "UserAssignment"
        user_assignment = UserAssignment.find(comment.commentable_id)
        assignment = Assignment.find(user_assignment.assignment_id)

        assignee_id = user_assignment.user_id
        assignor_id = assignment.user_id

        final_id_list = involved_users_ids + [assignee_id] + [assignor_id]
        # Don't send email to the user who just added the comment
        final_id_list = final_id_list.uniq - [current_user.id]

        recipients = User.where(:id => final_id_list)

        TaskMailer.task_comment_added({:recipients => recipients,
                                       :current_user => current_user,
                                       :task => assignment,
                                       :comment => comment}).deliver
      end
    end
  end

end
