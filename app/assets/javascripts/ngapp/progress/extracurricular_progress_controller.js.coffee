angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'UserExtracurricularActivityService', 'ProgressService',
  ($scope, UserExtracurricularActivityService, ProgressService) ->
    $scope.semester_activities = 0
    $scope.user_extracurricular_activities = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserExtracurricularActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_extracurricular_activities = []

            for detail in data.user_details
              for activity in data.user_extracurricular_activities
                if activity.id == detail.user_extracurricular_activity_id and
                detail.time_unit_id == $scope.selected_semester.id
                  activity.details = {}
                  activity.details = detail

            for activity in data.user_extracurricular_activities
              if !!activity.details
                $scope.user_extracurricular_activities.push(activity)

            console.log($scope.user_extracurricular_activities)

            $scope.$emit('loaded_module_milestones')

    $scope.$watch 'user_extracurricular_activities', () ->
      $scope.loaded_semester_activities = false
      $scope.semester_activities = 0
      for activity in $scope.user_extracurricular_activities
        if activity.details.time_unit_id == $scope.selected_semester.id
          $scope.semester_activities += 1

      $scope.loaded_semester_activities = true
    , true

    $scope.saveActivity = (index) ->
      new_extracurricular_activity = UserExtracurricularActivityService.newExtracurricularActivity($scope.student)
      new_extracurricular_activity.id = $scope.user_extracurricular_activities[index].id
      new_extracurricular_activity.name = $scope.user_extracurricular_activities[index].new_name
      new_extracurricular_activity.details.time_unit_id = $scope.selected_semester.id
      new_extracurricular_activity.details.leadership = $scope.user_extracurricular_activities[index].details.new_leadership
      new_extracurricular_activity.details.description = $scope.user_extracurricular_activities[index].details.new_description
      new_extracurricular_activity.details.user_extracurricular_activity_id =
      $scope.user_extracurricular_activities[index].id
      if !!$scope.user_extracurricular_activities[index].details.id
        new_extracurricular_activity.details.id =
        $scope.user_extracurricular_activities[index].details.id

      console.log($scope.user_extracurricular_activities[index])

      UserExtracurricularActivityService.saveExtracurricularActivityWithDetail(new_extracurricular_activity)
        .success (data) ->
          $scope.user_extracurricular_activities[index] = data.user_extracurricular_activity
          $scope.user_extracurricular_activities[index].details = data.user_details
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
      $scope.user_extracurricular_activities.push(UserExtracurricularActivityService.newExtracurricularActivity($scope.student))


    $scope.editActivity = (index) ->
      $scope.user_extracurricular_activities[index].editing = true
      $scope.user_extracurricular_activities[index].new_name= $scope.user_extracurricular_activities[index].name
      $scope.user_extracurricular_activities[index].details.new_leadership = $scope.user_extracurricular_activities[index].details.leadership
      $scope.user_extracurricular_activities[index].details.new_description = $scope.user_extracurricular_activities[index].details.description


]
