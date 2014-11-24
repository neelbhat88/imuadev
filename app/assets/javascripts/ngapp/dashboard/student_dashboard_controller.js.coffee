angular.module('myApp')
.controller "StudentDashboardController", ["$scope", "ProgressService", "OrganizationService", "UsersService", "ExpectationService", "AssignmentService",
($scope, ProgressService, OrganizationService, UsersService, ExpectationService, AssignmentService) ->

  setMiddleDimensions = () ->
    windowWidth = $(window).outerWidth()
    contentWidth = $('.dashboard-header--student').outerWidth()
    sideNavWidth = $('.mentor-list').outerWidth()
    if contentWidth >= windowWidth
      $('.middle-content-container').width(contentWidth - sideNavWidth - 260)
    else
      $('.middle-content-container').width(windowWidth - sideNavWidth - 260)

    height = $(window).outerHeight() - $('.dashboard-header--student').height()
    $('.middle-content-container').height(height)

  $(window).resize (event) -> setMiddleDimensions()

  ProgressService.getStudentDashboard($scope.user.id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      $scope.student = $scope.organization.students[0]
      $scope.student_with_modules_progress = _.omit($scope.student, ['user_assignments', 'mentors'])
      $scope.student_mentors = $scope.student.mentors

      current_org_milestones = _.filter($scope.organization.milestones, (m) -> m.time_unit_id == $scope.student.time_unit_id)
      current_user_milestones = _.filter($scope.student_with_modules_progress.user_milestones, (m) -> m.time_unit_id == $scope.student.time_unit_id)
      $scope.milestones = UsersService.determineEarnedMilestones(current_org_milestones, current_user_milestones)

      $scope.expectations = $scope.organization.expectations
      for expectation in $scope.expectations
        user_expectation = _.find($scope.student.user_expectations, (ue) -> ue.expectation_id == expectation.id)
        if user_expectation != undefined
          expectation.user_expectation = user_expectation

      $scope.meetingExpectations = $scope.student.meeting_expectations
      $scope.user_assignments = $scope.student.user_assignments
      $scope.needs_attention = $scope.student.needs_attention

      $scope.loaded_data = true

      setMiddleDimensions()


]
