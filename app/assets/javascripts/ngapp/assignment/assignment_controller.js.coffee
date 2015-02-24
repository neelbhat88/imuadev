angular.module('myApp')
.controller 'AssignmentController', ['$scope', '$route', 'current_user', 'assignment', 'edit', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, assignment, edit, AssignmentService, UsersService, OrganizationService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user

    $scope.user_assignments_total = []
    $scope.user_assignments_completed = []
    $scope.user_assignments_incomplete = []

    $scope.recalculateCompletion = () =>
      $scope.user_assignments_total = $scope.assignment.user_assignments
      $scope.user_assignments_completed = _.where($scope.user_assignments_total, {status: 1})
      $scope.user_assignments_incomplete = _.where($scope.user_assignments_total, {status: 0})

      $scope.percent_complete = 0
      if $scope.user_assignments_total.length > 0
        $scope.percent_complete = (($scope.user_assignments_completed.length / $scope.user_assignments_total.length) * 100).toFixed(0)

      if current_user.is_mentor
        assignable_user_ids = $scope.current_user.assigned_users.concat([$scope.current_user.id])
        $scope.user_assignments_completed = _.filter($scope.user_assignments_completed, (ua) -> _.contains(assignable_user_ids, ua.user.id))
        $scope.user_assignments_incomplete = _.filter($scope.user_assignments_incomplete, (ua) -> _.contains(assignable_user_ids, ua.user.id))

    if !assignment
      $scope.assignment = AssignmentService.newAssignment('User', $scope.current_user.id)
      $scope.assignment.editing = true
      $scope.user = $scope.current_user
    else
      $scope.assignment = assignment
      $scope.assignment.editing = edit
      $scope.user = $scope.assignment.user
      $scope.recalculateCompletion()

    if $scope.assignment.editing
      $scope.assignment.new_title = $scope.assignment.title
      $scope.assignment.new_description = $scope.assignment.description
      $scope.assignment.new_due_datetime = $scope.assignment.due_datetime

    $scope.assignment.assignees = []
    $scope.assignable_users = []

    $('input, textarea').placeholder()

    if $scope.current_user.id == $scope.user.id
      AssignmentService.getTaskAssignableUsers('User', $scope.user.id)
        .success (data) ->
          $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
          $scope.assignable_users = $scope.organization.users

          $scope.assignable_user_groups = []
          $scope.assignable_user_groups.push({group_name: "Org Admins", group_users: $scope.organization.orgAdmins})
          $scope.assignable_user_groups.push({group_name: "Mentors", group_users: $scope.organization.mentors})
          $scope.assignable_user_groups.push({group_name: "Students", group_users: $scope.organization.students})

          $scope.loaded_assignable_users = true
    else
      $scope.loaded_assignable_users = true

    $scope.editAssignment = () ->
      $scope.assignment.editing = true
      $scope.assignment.new_title = $scope.assignment.title
      $scope.assignment.new_description = $scope.assignment.description
      $scope.assignment.new_due_datetime = $scope.assignment.due_datetime

    $scope.cancelEditAssignment = () ->
      # Go back to assignments page if cancelled creating a new task
      if !$scope.assignment.id
        window.location.href = "app#/assignments/" + $scope.user.id
      else
        $scope.assignment.editing = false

    $scope.saveAssignment = (index) ->
      new_assignment = AssignmentService.newAssignment($scope.user.id)
      new_assignment.id = $scope.assignment.id
      new_assignment.assignment_owner_type = $scope.assignment.assignment_owner_type
      new_assignment.assignment_owner_id = $scope.assignment.assignment_owner_id
      new_assignment.title = $scope.assignment.new_title
      new_assignment.description = $scope.assignment.new_description
      new_assignment.due_datetime = $scope.assignment.new_due_datetime
      new_assignment.assignees = $scope.assignment.assignees

      AssignmentService.broadcastAssignment(new_assignment, _.map(new_assignment.assignees, (assignee) -> assignee.id))
        .success (data) ->
          organization = OrganizationService.parseOrganizationWithUsers(data.organization)
          saved_assignment =  organization.assignments[0]
          saved_assignment.assignees = []
          $scope.assignment = saved_assignment
          $scope.assignment.editing = false
          $scope.recalculateCompletion()

    $scope.deleteAssignment = () ->
      if window.confirm "Are you sure you want to delete this task?"
        AssignmentService.deleteAssignment($scope.assignment.id)
          .success (data) ->
            $scope.assignment.editing = false
            $scope.assignment = null
            window.location.href = "app#/assignments/" + $scope.user.id

    $scope.assignAllAssignableUsers = (assignment) ->
      all_assignable_user_ids = _.difference(_.pluck($scope.assignable_users, 'id'), _.pluck($scope.assignment.user_assignments, 'user_id'))
      assignment.assignees = _.filter($scope.assignable_users, (user) -> _.contains(all_assignable_user_ids, user.id))

    $scope.assignAssignee = (user, assignment) ->
      assignment.assignees.push(user)

    $scope.unassignAssignee = (user, assignment) ->
      assignment.assignees = _.without(assignment.assignees, user)

    $scope.setUserAssignmentStatus = (user_assignment, status) ->
      AssignmentService.setUserAssignmentStatus(user_assignment, status)
        .then () ->
          $scope.recalculateCompletion()

    $scope.deleteUserAssignment = (assignment, user_assignment) ->
      if window.confirm "Are you sure you want to delete this user's assignment?"
        AssignmentService.deleteUserAssignment(user_assignment.id)
          .success (data) ->
            assignment.user_assignments = _.without(assignment.user_assignments, user_assignment)
            $scope.recalculateCompletion()

    $scope.deleteUserFromAssignment = (assignment, user) ->
      user_assignment = _.find(assignment.user_assignments, (ua) -> ua.user_id == user.id)
      this.deleteUserAssignment(assignment, user_assignment)

    $scope.isPendingAssignment = (assignment, user) ->
      _.contains(_.pluck(assignment.assignees, 'id'), user.id)

    $scope.isAssigned = (assignment, user) ->
      _.contains(_.pluck(assignment.user_assignments, 'user_id'), user.id)

    $scope.isUnassigned = (assignment, user) ->
      !this.isPendingAssignment(assignment, user) && !this.isAssigned(assignment, user)

    $scope.isPastDue = (assignment) ->
      due_datetime = if assignment.editing then assignment.new_due_datetime else assignment.due_datetime
      if !due_datetime
        return false
      due_date = new Date(due_datetime).getTime()
      return due_date < $scope.today

    $scope.isDueSoon = (assignment) ->
      due_datetime = if assignment.editing then assignment.new_due_datetime else assignment.due_datetime
      if !due_datetime
        return false
      due_date = new Date(due_datetime).getTime()
      return !this.isPastDue(assignment) && due_date <= $scope.two_days_from_now

    $scope.isComplete = (assignment) ->
      return $scope.user_assignments_incomplete.length == 0


]
