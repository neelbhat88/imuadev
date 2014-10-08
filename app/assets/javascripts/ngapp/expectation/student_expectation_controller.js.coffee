angular.module('myApp')
.controller 'StudentExpectationController', ['$route', '$scope', '$location', 'student', 'current_user', 'ExpectationService', 'ProgressService', 'OrganizationService',
  ($route, $scope, $location, student, current_user, ExpectationService, ProgressService, OrganizationService) ->

    $scope.current_user = current_user
    $scope.student = student
    $scope.orgId = $scope.student.organization_id
    $scope.studentId = $scope.student.id
    $scope.meetingExpectations = true

    $scope.expectations = []

    ProgressService.getStudentExpectations($scope.student.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.student = $scope.organization.students[0]
        $scope.student_with_modules_progress = $scope.student

        $scope.expectations = $scope.organization.expectations
        for expectation in $scope.expectations
          user_expectation = _.find($scope.student.user_expectations, (ue) -> ue.expectation_id == expectation.id)
          if user_expectation != undefined
            expectation.user_expectation = user_expectation
        $scope.recalculateMeetingExpectations()
        $scope.loaded_data = true

    $scope.hideExpectationHistory = (expectation) ->
      expectation.user_expectation.showHistory = false

    $scope.recalculateMeetingExpectations = () ->
      for expectation in $scope.expectations
        if expectation.user_expectation.status > 0
          $scope.meetingExpectations = false
          return
      $scope.meetingExpectations = true

    $scope.viewExpectation = (user_expectation_id) ->
      $location.path("/user/#{student.id}/user_expectation/#{user_expectation_id}")

]
