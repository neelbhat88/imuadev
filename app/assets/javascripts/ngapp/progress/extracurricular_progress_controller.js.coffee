angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'UserExtracurricularActivityService', 'ProgressService',
  ($scope, UserExtracurricularActivityService, ProgressService) ->
    $scope.user_extracurricular_activities = []
    $scope.semester_activities = 0

    $scope.$watch 'user_extracurricular_activities', () ->
      $scope.loaded_semester_activities = false
      $scope.semester_activities = 0
      for activity in $scope.user_extracurricular_activities
        if activity.time_unit_id >= $scope.selected_semester.id
          $scope.semester_activities += 1

      $scope.loaded_semester_activities = true
    , true

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserExtracurricularActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_extracurricular_activities = data.user_extracurricular_activities

            for user_extracurricular_activity in $scope.user_extracurricular_activities
              if user_extracurricular_activity.time_unit_id >= $scope.selected_semester.id
                user_extracurricular_activity.events = []
                for user_extracurricular_activity_event in data.user_extracurricular_activity_events
                  if user_extracurricular_activity.id == user_extracurricular_activity_event.user_extracurricular_activity_id
                    user_extracurricular_activity.events.push(user_extracurricular_activity_event)

            $scope.$emit('loaded_module_milestones')

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.$emit('loaded_module_milestones')

    $scope.saveActivity = (index) ->
      if !!$scope.user_extracurricular_activities[index].events[0].id
        event_id = $scope.user_extracurricular_activities[index].events[0].id
      new_extracurricular_activity = UserExtracurricularActivityService.newExtracurricularActivity($scope.student, $scope.selected_semester.id)
      new_extracurricular_activity.id = $scope.user_extracurricular_activities[index].id
      new_extracurricular_activity.name = $scope.user_extracurricular_activities[index].new_name
      new_extracurricular_activity.events[0].leadership = $scope.user_extracurricular_activities[index].events[0].new_leadership
      new_extracurricular_activity.events[0].description = $scope.user_extracurricular_activities[index].events[0].new_description
      if !!event_id
        new_extracurricular_activity.events[0].id = event_id

      UserExtracurricularActivityService.saveExtracurricularActivity(new_extracurricular_activity)
        .success (data) ->
          $scope.user_extracurricular_activities[index] = data.user_extracurricular_activity
          new_extracurricular_activity.events[0].user_extracurricular_activity_id = data.user_extracurricular_activity.id
          $scope.user_extracurricular_activities[index].events = []
          UserExtracurricularActivityService.saveExtracurricularEvent(new_extracurricular_activity.events[0])
            .success (data2) ->
              $scope.user_extracurricular_activities[index].events.push(data2.user_extracurricular_activity_event)
              $scope.refreshPoints()

      $scope.user_extracurricular_activities.editing = false

    $scope.deleteActivity = (index) ->
      if window.confirm "Are you sure you want to delete this activity?"
        UserExtracurricularActivityService.deleteExtracurricularActivity($scope.user_extracurricular_activities[index])
          .success (data) ->
            $scope.user_extracurricular_activities.splice(index, 1)
            $scope.refreshPoints()

    $scope.cancelActivityEdit = (index) ->
      if $scope.user_extracurricular_activities[index].id
        $scope.user_extracurricular_activities[index].editing = false
      else
        $scope.user_extracurricular_activities.splice(index, 1)

      $scope.user_extracurricular_activities.editing = false

    $scope.addActivity = (index) ->
      $scope.user_extracurricular_activities.editing = true
      $scope.user_extracurricular_activities.push(UserExtracurricularActivityService.newExtracurricularActivity($scope.student, $scope.selected_semester.id))


    $scope.editActivity = (index) ->
      $scope.user_extracurricular_activities[index].editing = true
      $scope.user_extracurricular_activities[index].new_name= $scope.user_extracurricular_activities[index].name
      $scope.user_extracurricular_activities[index].events[0].new_leadership = $scope.user_extracurricular_activities[index].events[0].leadership
      $scope.user_extracurricular_activities[index].events[0].new_description = $scope.user_extracurricular_activities[index].events[0].description


]
