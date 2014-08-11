angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'UserExtracurricularActivityService', 'ProgressService',
  ($scope, UserExtracurricularActivityService, ProgressService) ->
    $scope.user_extracurricular_activities = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserExtracurricularActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_extracurricular_activities = data.user_extracurricular_activities

            for user_extracurricular_activity in $scope.user_extracurricular_activities
              user_extracurricular_activity.events = []
              for user_extracurricular_activity_event in data.user_extracurricular_activity_events
                if user_extracurricular_activity.id == user_extracurricular_activity_event.user_extracurricular_activity_id
                  user_extracurricular_activity.events.push(user_extracurricular_activity_event)

            console.log($scope.user_extracurricular_activities)
            $scope.$emit('loaded_module_milestones')
    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones')

    $scope.saveActivity = (index) ->
      new_extracurricular_activity = UserExtracurricularActivityService.newExtracurricularActivity($scope.student, $scope.selected_semester.id)
      new_extracurricular_activity.id = $scope.user_extracurricular_activities[index].id
      new_extracurricular_activity.name = $scope.user_extracurricular_activities[index].new_name
      extracurricular_events = $scope.user_extracurricular_activities[index].events

      UserExtracurricularActivityService.saveExtracurricularActivity(new_extracurricular_activity)
        .success (data) ->
          $scope.user_extracurricular_activities[index] = data.user_extracurricular_activity
          $scope.user_extracurricular_activities[index].events = extracurricular_events
          $scope.user_extracurricular_activities.editing = false
          $scope.refreshPoints()

    $scope.saveEvent = (parentIndex, index, extracurricularActivityId) ->
      new_extracurricular_event = UserExtracurricularActivityService.newExtracurricularEvent($scope.student, $scope.selected_semester.id, extracurricularActivityId)
      new_extracurricular_event.id = $scope.user_extracurricular_activities[parentIndex].events[index].id
      new_extracurricular_event.description = $scope.user_extracurricular_activities[parentIndex].events[index].new_description
      new_extracurricular_event.leadership= $scope.user_extracurricular_activities[parentIndex].events[index].new_leadership

      UserExtracurricularActivityService.saveExtracurricularEvent(new_extracurricular_event)
        .success (data) ->
          $scope.user_extracurricular_activities[parentIndex].events[index] = data.user_extracurricular_activity_event
          $scope.user_extracurricular_activities[parentIndex].events[index].editing = false
          $scope.refreshPoints()

    $scope.deleteActivity = (index) ->
      if window.confirm "Are you sure you want to delete this activity?"
        UserExtracurricularActivityService.deleteExtracurricularActivity($scope.user_extracurricular_activities[index])
          .success (data) ->
            $scope.user_extracurricular_activities.splice(index, 1)
            $scope.refreshPoints()

    $scope.deleteEvent = (parentIndex, index) ->
      if window.confirm "Are you sure you want to delete this event?"
        UserExtracurricularActivityService.deleteExtracurricularEvent($scope.user_extracurricular_activities[parentIndex].events[index])
          .success (data) ->
            $scope.user_extracurricular_activities[parentIndex].events.splice(index, 1)
            $scope.refreshPoints()

    $scope.cancelActivityEdit = (index) ->
      if $scope.user_extracurricular_activities[index].id
        $scope.user_extracurricular_activities[index].editing = false
      else
        $scope.user_extracurricular_activities.splice(index, 1)

      $scope.user_extracurricular_activities.editing = false

    $scope.cancelEventEdit= (parentIndex, index) ->
      if $scope.user_extracurricular_activities[parentIndex].events[index].id
        $scope.user_extracurricular_activities[parentIndex].events[index].editing = false
      else
        $scope.user_extracurricular_activities[parentIndex].events.splice(index, 1)
      $scope.user_extracurricular_activities[parentIndex].events.editing = false

    $scope.addActivity = () ->
      $scope.user_extracurricular_activities.editing = true
      $scope.user_extracurricular_activities.push(UserExtracurricularActivityService.newExtracurricularActivity($scope.student, $scope.selected_semester.id))

    $scope.addEvent= (index, user_extracurricular_activity_id) ->
      if !!$scope.user_extracurricular_activities[index].events
        $scope.user_extracurricular_activities[index].events.editing = true
        $scope.user_extracurricular_activities[index].events.push(UserExtracurricularActivityService.newExtracurricularEvent($scope.student, $scope.selected_semester.id, user_extracurricular_activity_id))
      else
        $scope.user_extracurricular_activities[index].events = []
        $scope.user_extracurricular_activities[index].events.push(UserExtracurricularActivityService.newExtracurricularEvent($scope.student, $scope.selected_semester.id, user_extracurricular_activity_id))

    $scope.editActivity= (index) ->
      $scope.user_extracurricular_activities[index].editing = true
      $scope.user_extracurricular_activities[index].new_name= $scope.user_extracurricular_activities[index].name

    $scope.editEvent = (parentIndex, index) ->
      $scope.user_extracurricular_activities[parentIndex].events[index].editing = true
      $scope.user_extracurricular_activities[parentIndex].events[index].new_description = $scope.user_extracurricular_activities[parentIndex].events[index].description
      $scope.user_extracurricular_activities[parentIndex].events[index].new_leadership= $scope.user_extracurricular_activities[parentIndex].events[index].leadership

]
