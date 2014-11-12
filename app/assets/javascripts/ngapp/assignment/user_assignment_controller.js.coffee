angular.module('myApp')
.controller 'UserAssignmentController', ['$scope', '$route', 'current_user', 'user_assignment', 'AssignmentService', 'UsersService', 'OrganizationService', 'CommentService',
  ($scope, $route, current_user, user_assignment, AssignmentService, UsersService, OrganizationService, CommentService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user
    $scope.user_assignment = user_assignment
    $scope.assigner = $scope.user_assignment.assigner
    $scope.loaded = true

    $('input, textarea').placeholder()

    $scope.setUserAssignmentStatus = (user_assignment, status) ->
      new_user_assignment = AssignmentService.newUserAssignment(user_assignment.user_id, user_assignment.assignment_id)
      new_user_assignment.id = user_assignment.id
      new_user_assignment.status = status

      AssignmentService.saveUserAssignment(new_user_assignment)
        .success (data) ->
          user_assignment.status = data.user_assignment.status
          user_assignment.updated_at = new Date()

    $scope.isComplete = (user_assignment) ->
      return user_assignment.status == 1

    $scope.isPastDue = (user_assignment) ->
      if user_assignment.due_datetime == null
        return false
      due_date = new Date(user_assignment.due_datetime).getTime()
      return due_date < $scope.today

    $scope.isDueSoon = (user_assignment) ->
      if user_assignment.due_datetime == null
        return false
      due_date = new Date(user_assignment.due_datetime).getTime()
      return !this.isPastDue(user_assignment) && due_date <= $scope.two_days_from_now


    $scope.addNewComment = (commentable_object) ->
      commentable_object.editing_new_comment = true
      commentable_object.new_comment = ""

    $scope.cancelAddNewComment = (commentable_object) ->
      commentable_object.editing_new_comment = false

    $scope.saveNewComment = (commentable_object) ->
      CommentService.saveNewComment("user_assignment", commentable_object.id, commentable_object.new_comment)
        .then (saved_comment) ->
          if commentable_object.comments == undefined || commentable_object.comments == null
            commentable_object.comments = []
          saved_comment.user = current_user
          commentable_object.comments.push(saved_comment)
          commentable_object.editing_new_comment = false

]
