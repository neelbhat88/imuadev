class Api::V1::UserAssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil, commentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new
    @commentService = commentService ? commentService : CommentService.new(current_user)
  end
  # GET /users/:user_id/user_assignment
  # Returns all UserAssignments for the given User
  def index
    userId = params[:user_id]

    if !can?(current_user, :get_user_assignments, User.where(id: params[:user_id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.get_user_assignments(userId)

    render status: :ok,
      json: {
        info: "user_assignments",
        user_assignments: result
      }
  end

  # POST /users/:user_id/user_assignment
  # Creates a UserAssignment for the given User
  def create
    userId         = params[:user_id].to_i
    userAssignment = params[:user_assignment]

    userAssignment["user_id"] = userId

    if !can?(current_user, :create_user_assignment, User.where(id: params[:user_id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.create_user_assignment(userAssignment)

    render status: result.status,
      json: {
        info: result.info,
        user_assignment: result.object
      }
  end

  # PUT /user_assignment/:id
  # Updates a UserAssignment
  def update
    userAssignmentId = params[:id].to_i
    userAssignment   = params[:user_assignment]

    userAssignment["id"] = userAssignmentId

    if !can?(current_user, :update_user_assignment, UserAssignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.update_user_assignment(current_user, userAssignment)

    render status: result.status,
      json: {
        info: result.info,
        user_assignment: result.object
      }
  end

  # DELETE /user_assignment/:id
  # Deletes a UserAssignment
  def destroy
    userAssignmentId = params[:id].to_i

    if !can?(current_user, :destroy_user_assignment, UserAssignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.delete_user_assignment(userAssignmentId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

  # GET /user_assignment/:id/collect
  # Returns the UserAssignment with associated Assignment data
  def collect
    userAssignmentId = params[:id].to_i

    if !can?(current_user, :get_user_assignment_collection, UserAssignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.collect_user_assignment(userAssignmentId)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

    # GET /user_assignment/:id/collect
  # Returns the UserAssignment with associated Assignment data
  def collect_old
    userAssignmentId = params[:id].to_i

    if !can?(current_user, :get_user_assignment_collection, UserAssignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.collect_user_assignment(userAssignmentId)
    viewUserAssignment = ViewUserAssignment.new(result, {assignment: true, user: true})

    render status: :ok,
      json: {
        info: "UserAssignment id: #{userAssignmentId}.",
        user_assignment: viewUserAssignment
      }
  end

  # GET /users/:user_id/assignment/collect
  # Returns all of a User's UserAssignments with their associated Assignment data
  def collect_all
    userId = params[:user_id].to_i

    if !can?(current_user, :get_user_assignment_collections, User.where(id: params[:user_id]).first)
      render status: :forbidden, json: {}
      return
    end

    results = @assignmentService.collect_user_assignments(userId)
    viewUserAssignments = results.map{|r| ViewUserAssignment.new(r, {assignment: true})}

    render status: :ok,
      json: {
        info: "UserAssignments for use id: #{userId}.",
        user_assignments: viewUserAssignments
      }
  end

  # POST /user_assignment/:id/comment
  def comment
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:commentable_id] = params[:id]
    service_params[:target_table] = UserAssignment

    commentable_object = service_params[:target_table].where(id: service_params[:commentable_id]).first
    if !can?(@current_user, :create_comment, commentable_object)
      render status: :forbidden, json: {}
      return
    end

    result = @commentService.create(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /user_assignment/:id/comments
  def comments
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:commentable_id] = params[:id]
    service_params[:target_table] = UserAssignment

    commentable_object = service_params[:target_table].where(id: service_params[:commentable_id]).first
    if !can?(@current_user, :index_comments, commentable_object)
      render status: :forbidden, json: {}
      return
    end

    result = @commentService.index(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

end
