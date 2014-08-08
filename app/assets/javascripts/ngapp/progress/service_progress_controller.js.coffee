angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceActivityService', 'ProgressService',
  ($scope, UserServiceActivityService, ProgressService) ->
    $scope.user_service_activities = []
    $scope.user_service_activity_events = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserServiceActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_service_activities = data.user_service_activities
            $scope.user_service_activity_events = data.user_service_activity_events

            for user_service_activity in $scope.user_service_activities
              user_service_activity.events = []
              for user_service_activity_event in $scope.user_service_activity_events
                if user_service_activity.id == user_service_activity_event.user_service_activity_id
                  user_service_activity.events.push(user_service_activity_event)

            console.log($scope.user_service_activities)
            $scope.$emit('loaded_module_milestones')
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones')

    $scope.saveActivity = (index) ->
      new_service_activity = UserServiceActivityService.newServiceActivity($scope.student, $scope.selected_semester.id)
      new_service_activity.id = $scope.user_service_activities[index].id
      new_service_activity.name = $scope.user_service_activities[index].new_name
      new_service_activity.description = $scope.user_service_activities[index].new_description

      UserServiceActivityService.saveServiceActivity(new_service_activity)
        .success (data) ->
          $scope.user_service_activities[index] = data.user_class
          $scope.classes.editing = false

          $scope.refreshPoints()

    $scope.saveEvent = (index) ->
      new_service_event = UserServiceActivityService.newServiceEvent($scope.student, $scope.selected_semester.id)
      new_service_event.id = $scope.user_service_activity_events[index].id
      new_service_event.name = $scope.user_service_activity_events[index].new_name
      new_service_event.grade = $scope.user_service_activity_events[index].new_grade

      UserServiceActivityService.saveServiceEvent(new_service_event)
        .success (data) ->
          $scope.user_service_activities[index] = data.user_class
          $scope.classes.editing = false

          $scope.refreshPoints()

    $scope.deleteActivity = (index) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserServiceActivityService.deleteServiceActivity($scope.user_service_activities[index])
          .success (data) ->
            $scope.user_service_activities.splice(index, 1)
            $scope.refreshPoints()

    $scope.deleteEvent = (index) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserServiceActivityService.deleteServiceEvent($scope.user_service_activity_events[index])
          .success (data) ->
            $scope.user_service_activity_events.splice(index, 1)
            $scope.refreshPoints()

    $scope.cancelActivityEdit = (index) ->
      if $scope.user_service_activities[index].id
        $scope.user_service_activities[index].editing = false
      else
        $scope.user_service_activities.splice(index, 1)

      $scope.user_service_activities.editing = false

    $scope.cancelEventEdit= (parentIndex, index) ->
      if $scope.user_service_activities[parentIndex].events[index].id
        $scope.user_service_activities[parentIndex].events[index].editing = false
      else
        $scope.user_service_activities[parentIndex].events.splice(index, 1)

      $scope.user_service_activities[parentIndex].events.editing = false

    $scope.addActivity = () ->
      $scope.user_service_activities.editing = true
      $scope.user_service_activities.push(UserServiceActivityService.newServiceActivity($scope.student, $scope.selected_semester.id))

    $scope.addEvent= (index, user_service_activity_id) ->
      $scope.user_service_activities[index].events.editing = true
      $scope.user_service_activities[index].events.push(UserServiceActivityService.newServiceEvent($scope.student, $scope.selected_semester.id, user_service_activity_id))

    $scope.editActivity= (index) ->
      $scope.user_service_activities[index].editing = true
      $scope.user_service_activities[index].new_name= $scope.user_service_activities[index].name

    $scope.editEvent = (parentIndex, index) ->
      $scope.user_service_activities[parentIndex].events[index].editing = true
      $scope.user_service_activities[parentIndex].events[index].new_description = $scope.user_service_activities[parentIndex].events[index].description
      $scope.user_service_activities[parentIndex].events[index].new_hours = $scope.user_service_activities[parentIndex].events[index].hours

]
