class Api::V1::AssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new
  end

  # GET /users/:user_id/assignment
  # Returns all Assignments for the given User
  def index
    userId = params[:user_id]

    # if !can?(current_user, :get_assignments, User.where(id: params[:user_id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.get_assignments(userId)

    render status: :ok,
      json: { info: "assignments", assignments: result }
  end

  # GET /assignment/:id
  # Returns the Assignment
  def show
    assignmentId = params[:id]

    # if !can?(current_user, :get_assignment, Assignment.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.get_assignment(assignmentId)

    render status: :ok,
      json: { info: "assignment", assignments: result }
  end

  # POST /users/:user_id/assignment
  # Creates an Assignment for the given User
  def create
    userId     = params[:user_id].to_i
    assignment = params[:assignment]

    assignment["user_id"] = userId

    # if !can?(current_user, :create_assignment, User.where(id: params[:user_id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.create_assignment(assignment)

    render status: result.status,
      json: { info: result.info, assignment: result.object }
  end

  # PUT /assignment/:id
  # Updates an Assignment
  def update
    assignmentId = params[:id].to_i
    assignment   = params[:assignment]

    assignment["id"] = assignmentId

    # if !can?(current_user, :update_assignment, Assignment.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.update_assignment(assignment)

    render status: result.status,
      json: { info: result.info, assignment: result.object }
  end

  # DELETE /assignment/:id
  # Deletes an Assignment
  def destroy
    assignmentId = params[:id].to_i

    # if !can?(current_user, :delete_assignment, Assignment.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.delete_assignment(assignmentId)

    render status: result.status,
      json: { info: result.info }
  end

  # GET /assignment/:id/collection
  # Returns the Assignment with its collection of UserAssignments
  def get_assignment_collection
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:assignment_id] = params[:id]

    # if !can?(current_user, :get_assignment_collection, Assignment.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.get_assignment_collection(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # POST /users/:id/assignment/broadcast
  # Creates an Assignment and its collection of User Assignments
  def broadcast
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    # TODO Fix to incorporate authorizations for creating all the user_assignments
    # if !can?(current_user, :create_assignment_broadcast, User.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.broadcast(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # PUT /assignment/:id/broadcast
  # Updates an Assignment and its collection of UserAssignments
  def broadcast_update
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:assignment_id] = params[:id]

    # TODO Fix to incorporate authorizations for updating all the user_assignments
    # if !can?(current_user, :update_assignment_broadcast, Assignment.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.broadcast_update(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /users/:id/task_assignable_users
  def get_task_assignable_users
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    # if !can?(current_user, :get_task_assignable_users, User.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.get_task_assignable_users(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /users/:id/task_assignable_users_tasks
  def get_task_assignable_users_tasks
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    # if !can?(current_user, :get_task_assignable_users_tasks, User.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = @assignmentService.get_task_assignable_users_tasks(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

end
