angular.module('myApp')
.controller 'RoadmapController', ['$scope', '$modal', '$route', 'RoadmapService', 'LoadingService', 'OrganizationService', 'UsersService',
($scope, $modal, $route, RoadmapService, LoadingService, OrganizationService, UsersService) ->

  $scope.updateRoadmapName = (roadmap) ->
    if !roadmap.newname
      return

    RoadmapService.updateRoadmapName(roadmap, roadmap.newname)
    .success (data) ->
      $scope.roadmap.name = data.roadmap.name
      roadmap.editing = false

    .error (data) ->
      roadmap.editing = false

  $scope.addTimeUnit = (timeUnit) ->
    $scope.addingTimeUnit = true
    if timeUnit and timeUnit.id
      timeUnit.original = angular.copy(timeUnit)
      timeUnit.editing = true
    else
      newTimeUnit = { name: "", editing: true }
      $scope.roadmap.time_units.push(newTimeUnit)

  $scope.saveAddTimeUnit = (timeUnit) ->
    if !timeUnit.name
      return

    if timeUnit.id
      RoadmapService.updateTimeUnit(timeUnit).then (data) ->
        timeUnit.editing = false
        $scope.addingTimeUnit = false

    else
      RoadmapService.addTimeUnit(-1, $scope.roadmap.id, timeUnit).then (data) -> # Success
        # Remove the temp object and push the newly added one on
        $scope.roadmap.time_units.pop()
        $scope.roadmap.time_units.push(data.time_unit)

        $scope.addingTimeUnit = false
      , (data) -> # Error

  $scope.cancelAddTimeUnit = (timeUnit) ->
    if timeUnit.id # Editing an existing time_unit
      timeUnit.editing = false
      timeUnit.name = timeUnit.original.name
    else
      $scope.roadmap.time_units.pop()

    $scope.addingTimeUnit = false

  $scope.deleteTimeUnit = (index) ->
    if window.confirm "Are you sure? Deleting this will delete all milestones within it also."
      RoadmapService.deleteTimeUnit($scope.roadmap.time_units[index].id).then (data) -> # Success
        $scope.roadmap.time_units.splice(index, 1)
        $scope.addingTimeUnit = false

  $scope.addMilestone = (timeUnit, selected_module) ->
    modalInstance = $modal.open
      templateUrl: 'roadmap/add_milestone_modal.html',
      controller: 'AddMilestoneModalController',
      backdrop: 'static',
      resolve:
        timeUnit: () -> timeUnit
        enabledModules: () -> [selected_module]

    # TODO: Fix to be like edit milestone
    modalInstance.result.then (milestone) ->
      RoadmapService.addMilestone(milestone)
      .success (data) ->
        timeUnit.milestones.push(data.milestone)

  $scope.viewMilestone = (timeUnit, milestone) ->
    modalInstance = $modal.open
      templateUrl: 'roadmap/edit_milestone_modal.html',
      controller: 'EditMilestoneModalController',
      backdrop: 'static',
      resolve:
        selectedMilestone: () -> milestone
        timeUnit: () -> timeUnit
    modalInstance.result.then () ->

  $scope.viewMilestoneStatus = (milestone) ->
    window.location.href = "app#/milestone/" + milestone.id

  $scope.deleteMilestone = (tu, milestone) ->
    if window.confirm "Are you sure you want to delete this milestone?"
      for m,index in tu.milestones
        if m.id == milestone.id
          RoadmapService.deleteMilestone(tu.milestones[index].id)
          .success (data) ->
            tu.milestones.splice(index, 1)
          break

  $scope.addOrgAdmin = () ->
    modalInstance = $modal.open
      templateUrl: 'organization/add_user_modal.html',
      controller: 'AddUserModalController',
      backdrop: 'static',
      size: 'sm',
      resolve:
        current_user: () -> $scope.current_user
        organization: () -> $scope.organization
        new_user: () -> UsersService.newOrgAdmin($scope.organization.id)

    modalInstance.result.then (user) ->
      $scope.organization.orgAdmins.push(user)

]
