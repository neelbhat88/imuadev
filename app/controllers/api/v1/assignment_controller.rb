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

    result = @assignmentService.get_assignments(userId)

    render status: :ok,
      json: {
        info: "assignments",
        assignments: result
      }
  end

  # GET /assignment/:id
  # Returns the Assignment
  def show
    assignmentId = params[:id]

    result = @assignmentService.get_assignment(assignmentId)

    render status: :ok,
      json: {
        info: "assignment",
        assignments: result
      }
  end

  # POST /users/:user_id/assignment
  # Creates an Assignment for the given User
  def create
    userId     = params[:user_id].to_i
    assignment = params[:assignment]

    assignment["user_id"] = userId

    result = @assignmentService.create_assignment(assignment)

    render status: result.status,
      json: {
        info: result.info,
        assignment: result.object
      }
  end

  # PUT /assignment/:id
  # Updates an Assignment
  def update
    assignmentId = params[:id].to_i
    assignment   = params[:assignment]

    assignment["id"] = assignmentId

    result = @assignmentService.update_assignment(assignment)

    render status: result.status,
      json: {
        info: result.info,
        assignment: result.object
      }
  end

  # DELETE /assignment/:id
  # Deletes an Assignment
  def destroy
    assignmentId = params[:id].to_i

    result = @assignmentService.delete_assignment(assignmentId)

    render status: result.status,
      json: {
        info: result.info
      }
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

  # POST /users/:user_id/assignment/broadcast
  # Creates an Assignment and its collection of User Assignments
  def broadcast
    userId = params[:user_id].to_i
    assignment = params[:assignment]
    user_assignments = params[:user_assignments]

    assignment[:user_id] = userId
    assignmentResult = @assignmentService.create_assignment(assignment)
    viewAssignmentCollection = nil

    if assignmentResult.status == :ok
      userAssignmentResults = []
      user_assignments.each do |a|
        a[:assignment_id] = assignmentResult.object.id
        userAssignmentResults << @assignmentService.create_user_assignment(a)
      end

      # TODO What if a userAssignment operation fails?
      result = @assignmentService.collect_assignment(assignmentResult.object.id)
      viewAssignmentCollection = ViewAssignmentCollection.new(result)
    end

    render status: assignmentResult.status,
      json: {
        info: assignmentResult.info,
        assignment_collection: viewAssignmentCollection
      }
  end

  # PUT /assignment/:id/broadcast
  # Updates an Assignment and its collection of UserAssignments
  def broadcast_update
    assignmentId = params[:id].to_i
    assignment = params[:assignment]
    user_assignments = params[:user_assignments]

    assignment[:id] = assignmentId
    assignmentResult = @assignmentService.update_assignment(assignment)
    viewAssignmentCollection = nil

    if assignmentResult.status == :ok
      userAssignmentResults = []
      if user_assignments
        user_assignments.each do |a|
          Rails.logger.debug(a)
          a[:assignment_id] = assignmentResult.object.id
          if a[:id].nil?
            userAssignmentResults << @assignmentService.create_user_assignment(a)
          else
            userAssignmentResults << @assignmentService.update_user_assignment(a)
          end
        end
      end

      # TODO What if a userAssignment operation fails?
      result = @assignmentService.collect_assignment(assignmentResult.object.id)
      viewAssignmentCollection = ViewAssignmentCollection.new(result)
    end

    render status: assignmentResult.status,
      json: {
        info: assignmentResult.info,
        assignment_collection: viewAssignmentCollection
      }
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
