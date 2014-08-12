angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceActivityService', 'ProgressService',
  ($scope, UserServiceActivityService, ProgressService) ->
    $scope.user_service_activities = []
    $scope.semester_service_hours = 0

    $scope.$watch 'user_service_activities', () ->
      $scope.loaded_semester_service_hours = false
      $scope.semester_service_hours = 0
      for activity in $scope.user_service_activities
        if activity.events
          for event in activity.events
            if event.hours
              $scope.semester_service_hours += parseFloat event.hours
      $scope.loaded_semester_service_hours = true
    , true

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserServiceActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_service_activities = data.user_service_activities
            for user_service_activity in $scope.user_service_activities
              user_service_activity.events = []
              for user_service_activity_event in data.user_service_activity_events
                if user_service_activity.id == user_service_activity_event.user_service_activity_id
                  user_service_activity.events.push(user_service_activity_event)
<<<<<<< HEAD
=======

>>>>>>> master
            $scope.$emit('loaded_module_milestones')

    $scope.saveActivity = (index) ->
      new_service_activity = UserServiceActivityService.newServiceActivity($scope.student, $scope.selected_semester.id)
      new_service_activity.id = $scope.user_service_activities[index].id
      new_service_activity.name = $scope.user_service_activities[index].new_name
      service_events = $scope.user_service_activities[index].events

      UserServiceActivityService.saveServiceActivity(new_service_activity)
        .success (data) ->
          $scope.user_service_activities[index] = data.user_service_activity
          $scope.user_service_activities[index].events = service_events
          $scope.user_service_activities.editing = false
          $scope.refreshPoints()

    $scope.saveEvent = (parentIndex, index, serviceActivityId) ->
      new_service_event = UserServiceActivityService.newServiceEvent($scope.student, $scope.selected_semester.id, serviceActivityId)
      new_service_event.id = $scope.user_service_activities[parentIndex].events[index].id
      new_service_event.description = $scope.user_service_activities[parentIndex].events[index].new_description
      new_service_event.hours = $scope.user_service_activities[parentIndex].events[index].new_hours
      new_service_event.date = $scope.user_service_activities[parentIndex].events[index].new_date
      $scope.user_service_activities[parentIndex].events.editing = false

      UserServiceActivityService.saveServiceEvent(new_service_event)
        .success (data) ->
          $scope.user_service_activities[parentIndex].events[index] = data.user_service_activity_event
          $scope.user_service_activities[parentIndex].events[index].editing = false
          $scope.refreshPoints()

    $scope.deleteActivity = (index) ->
      if window.confirm "Are you sure you want to delete this activity?"
        UserServiceActivityService.deleteServiceActivity($scope.user_service_activities[index])
          .success (data) ->
            $scope.user_service_activities.splice(index, 1)
            $scope.refreshPoints()

    $scope.deleteEvent = (parentIndex, index) ->
      if window.confirm "Are you sure you want to delete this event?"
        UserServiceActivityService.deleteServiceEvent($scope.user_service_activities[parentIndex].events[index])
          .success (data) ->
            $scope.user_service_activities[parentIndex].events.splice(index, 1)
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
      if !!$scope.user_service_activities[index].events
        $scope.user_service_activities[index].events.editing = true
        $scope.user_service_activities[index].events.push(UserServiceActivityService.newServiceEvent($scope.student, $scope.selected_semester.id, user_service_activity_id))
      else
        $scope.user_service_activities[index].events = []
        $scope.user_service_activities[index].events.push(UserServiceActivityService.newServiceEvent($scope.student, $scope.selected_semester.id, user_service_activity_id))

    $scope.editActivity= (index) ->
      $scope.user_service_activities[index].editing = true
      $scope.user_service_activities[index].new_name= $scope.user_service_activities[index].name

    $scope.editEvent = (parentIndex, index) ->
      $scope.user_service_activities[parentIndex].events[index].editing = true
      $scope.user_service_activities[parentIndex].events[index].new_description = $scope.user_service_activities[parentIndex].events[index].description
      $scope.user_service_activities[parentIndex].events[index].new_hours = $scope.user_service_activities[parentIndex].events[index].hours
      $scope.user_service_activities[parentIndex].events[index].new_date= $scope.user_service_activities[parentIndex].events[index].date

]
