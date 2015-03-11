angular.module('myApp')
.controller 'ManageExpectationModalController', ['$scope', '$modalInstance', 'CONSTANTS', 'selectedStudents',
                                        'current_user', 'ExpectationService', 'OrganizationService',
  ($scope, $modalInstance, CONSTANTS, selectedStudents, current_user, ExpectationService, OrganizationService) ->

    $scope.current_user = current_user
    $scope.orgId = $scope.current_user.organization_id
    $scope.selectedStudents = selectedStudents

    $scope.recalculateCompletion = () =>
      partition = _.partition($scope.users_total, (u) -> !u.user_expectations or u.user_expectations[0].status == CONSTANTS.EXPECTATION_STATUS.meeting)
      $scope.users_meeting = partition[0]
      partition_2 = _.partition(partition[1], (u) -> u.user_expectations[0].status == CONSTANTS.EXPECTATION_STATUS.needs_work)
      $scope.users_need_work = partition_2[0]
      $scope.users_not_meeting = partition_2[1]

    ExpectationService.getExpectations($scope.orgId)
      .success (data) ->
        $scope.expectations = data.expectations
        for e in $scope.expectations
          e.editing = false
        $scope.expectations.editing = false

    $scope.editExpectation = (expectation) ->
      $scope.expectations.editing = true
      ExpectationService.getExpectationStatus(expectation.id)
        .success (data) ->
          $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
          $scope.users_total = []
          for student in selectedStudents
            $scope.users_total.push(_.findWhere($scope.organization.students, {id: student.id}))
          console.log($scope.users_total)
          $scope.expectation = $scope.organization.expectations[0]
          $scope.recalculateCompletion()
          $scope.expectation.new_comment = ""
          $scope.expectation.assignees = []

    $scope.assignUserExpectationStatus = (user, status) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      $scope.expectation.assignees = _.reject($scope.expectation.assignees, (a) -> a.user.id == user.id)
      # Handle the "unclicked" case
      if assignment == undefined || assignment.status != status
        $scope.expectation.assignees.push({user: user, status: status})

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

    $scope.isAssignedMeeting = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == CONSTANTS.EXPECTATION_STATUS.meeting

    $scope.isAssignedNeedsWork = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == CONSTANTS.EXPECTATION_STATUS.needs_work

    $scope.isAssignedNotMeeting = (user) ->
      assignment = _.find($scope.expectation.assignees, (a) -> a.user.id == user.id)
      return assignment != undefined && assignment.status == CONSTANTS.EXPECTATION_STATUS.not_meeting
]
