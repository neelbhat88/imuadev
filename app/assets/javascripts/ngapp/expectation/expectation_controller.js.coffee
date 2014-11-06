angular.module('myApp')
.controller 'ExpectationController', ['$scope', '$route', 'current_user', 'expectation_id', 'ExpectationService', 'UsersService', 'OrganizationService', 'RoadmapService', 'ProgressService',
  ($scope, $route, current_user, expectation_id, ExpectationService, UsersService, OrganizationService, RoadmapService, ProgressService) ->

    $scope.current_user = current_user

    $scope.recalculateCompletion = () =>
      partition = _.partition($scope.users_total, (u) -> !u.user_expectations or u.user_expectations[0].status == $scope.CONSTANTS.EXPECTATION_STATUS.meeting)
      $scope.users_meeting = partition[0]
      partition_2 = _.partition(partition[1], (u) -> u.user_expectations[0].status == $scope.CONSTANTS.EXPECTATION_STATUS.needs_work)
      $scope.users_need_work = partition_2[0]
      $scope.users_not_meeting = partition_2[1]
      $scope.percent_meeting = 0
      $scope.percent_need_work = 0
      $scope.percent_not_meeting = 0

      if $scope.users_total.length > 0
        $scope.percent_meeting = (($scope.users_meeting.length / $scope.users_total.length) * 100).toFixed(0)
        $scope.percent_need_work = (($scope.users_need_work.length / $scope.users_total.length) * 100).toFixed(0)
        $scope.percent_not_meeting = (($scope.users_not_meeting.length / $scope.users_total.length) * 100).toFixed(0)

      if current_user.is_mentor
        $scope.users_meeting = _.filter($scope.users_meeting, (u) -> _.contains(current_user.assigned_users, u.id))
        $scope.users_need_work = _.filter($scope.users_need_work, (u) -> _.contains(current_user.assigned_users, u.id))
        $scope.users_not_meeting = _.filter($scope.not_meeting, (u) -> _.contains(current_user.assigned_users, u.id))

    ExpectationService.getExpectationStatus(expectation_id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.users_total = $scope.organization.students
        $scope.expectation = $scope.organization.expectations[0]
        $scope.recalculateCompletion()
        $scope.loaded_data = true

    $scope.setExpectationStatus = () ->
      $scope.new_status_comment = ""
      $scope.expectation.assignees = []
      $scope.expectation.assigning = true

    $scope.cancelSetExpectationStatus = () ->
      $scope.expectation.assigning = false

    $scope.saveExpectationStatus = () ->
      # ExpectationService.setUserExpectation(user, status, expectation_id)
      #   .success (data) ->
      #     if !user.user_expectations
      #       user.user_expectations = []
      #     user.user_expectations.push({})
      #     $scope.recalculateCompletion()
      #     $scope.expectation.assigning = false
      $scope.expectation.assigning = false

    $scope.assignUserExpectationStatus = (user, status) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      $scope.expectation.assignees = _.reject($scope.expectation.assignees, (a) -> a.user.id == user.id)
      if !(assignment != undefined && assignment.status == status)
        $scope.expectation.assignees.push({user: user, status: status})

    $scope.isAssignedMeeting = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == $scope.CONSTANTS.EXPECTATION_STATUS.meeting

    $scope.isAssignedNeedsWork = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == $scope.CONSTANTS.EXPECTATION_STATUS.needs_work

    $scope.isAssignedNotMeeting = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == $scope.CONSTANTS.EXPECTATION_STATUS.not_meeting

]
