angular.module('myApp')
.controller 'ExtracurricularProgressController', ['$scope', 'UserExtracurricularActivityService', 'ProgressService',
  ($scope, UserExtracurricularActivityService, ProgressService) ->
    $scope.semester_activities = 0
    $scope.user_extracurricular_activities = []
    $scope.previous_activity_list = []
    current_activities = []
    other_activity = {}

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserExtracurricularActivityService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_extracurricular_activities = []
            $scope.previous_activity_list = []
            current_activities = []
            current_activities = data.user_extracurricular_activities

            $scope.org_current_activity_list = data.org_extracurricular_activity_titles

            for activity in current_activities
              activity.details = []
              for detail in data.user_extracurricular_details
                if activity.id == detail.user_extracurricular_activity_id and
                detail.time_unit_id == $scope.selected_semester.id
                  activity.details.push(detail)

            for user_extracurricular_activity in current_activities
              if user_extracurricular_activity.details.length > 0
                $scope.user_extracurricular_activities.push(user_extracurricular_activity)
              else
                $scope.previous_activity_list.push(user_extracurricular_activity)

            other_activity = {}
            other_activity = UserExtracurricularActivityService
              .otherActivity($scope.student, $scope.selected_semester.id, null)
            $scope.previous_activity_list.push(other_activity)

            $scope.$emit('loaded_module_milestones')

    $scope.$watch 'user_extracurricular_activities', () ->
      $scope.loaded_semester_activities = false
      $scope.semester_activities = 0
      for activity in $scope.user_extracurricular_activities
        $scope.semester_activities += 1

      $scope.loaded_semester_activities = true
    , true

    $scope.saveActivity = (index) ->
      UserExtracurricularActivityService.saveExtracurricularActivity($scope.user_extracurricular_activities[index])
        .success (data) ->
          $scope.user_extracurricular_activities[index] = data.user_extracurricular_activity
          $scope.user_extracurricular_activities[index].details = []
          $scope.user_extracurricular_activities[index].details.push(data.user_extracurricular_detail)
          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Extracurricular')

      $scope.user_extracurricular_activities.editing = false

    $scope.saveNewActivity = (index) ->
      if $scope.new_extracurricular_activity.details[0].user_extracurricular_activity_id
        UserExtracurricularActivityService.saveExtracurricularDetail($scope.new_extracurricular_activity.details[0])
            .success (data) ->
              $scope.new_extracurricular_activity.details = []
              $scope.new_extracurricular_activity.details.push(data.user_extracurricular_detail)
              $scope.user_extracurricular_activities.push($scope.new_extracurricular_activity)
              $scope.new_extracurricular_activity.editing = false
              $scope.user_extracurricular_activities.editing = false
              # reset previous activity list
              $scope.previous_activity_list = _.filter($scope.previous_activity_list, (activity) ->
                activity.id != data.user_extracurricular_detail.user_extracurricular_activity_id)

              $scope.refreshPoints()
              $scope.$emit('just_updated', 'Extracurricular')
      else
        $scope.new_extracurricular_activity.name = $scope.new_extracurricular_activity.new_name
        UserExtracurricularActivityService.saveNewExtracurricularActivity($scope.new_extracurricular_activity)
          .success (data) ->
            data.user_extracurricular_activity.details = []
            data.user_extracurricular_activity.details.push(data.user_extracurricular_detail)
            $scope.user_extracurricular_activities.push(data.user_extracurricular_activity)
            $scope.new_extracurricular_activity.editing = false
            $scope.user_extracurricular_activities.editing = false
            # reset previous activity list
            $scope.previous_activity_list.pop()
            other_activity = {}
            other_activity = UserExtracurricularActivityService
              .otherActivity($scope.student, $scope.selected_semester.id, null)

            $scope.previous_activity_list.push(other_activity)

            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Extracurricular')

    $scope.deleteActivity = (index) ->
      if window.confirm "Are you sure you want to delete this activity?"
        UserExtracurricularActivityService.deleteExtracurricularActivity($scope.user_extracurricular_activities[index], $scope.selected_semester.id)
          .success (data) ->
            $scope.user_extracurricular_activities[index].details = []
            deletedActivity = $scope.user_extracurricular_activities.splice(index,1)
            $scope.previous_activity_list.pop()
            $scope.previous_activity_list.push(deletedActivity[0])
            other_activity = {}
            other_activity = UserExtracurricularActivityService
              .otherActivity($scope.student, $scope.selected_semester.id, null)

            $scope.previous_activity_list.push(other_activity)
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Extracurricular')

    $scope.cancelActivityEdit = (index) ->
      if $scope.user_extracurricular_activities[index].id
        $scope.user_extracurricular_activities[index].editing = false
      else
        $scope.user_extracurricular_activities.splice(index, 1)

      $scope.user_extracurricular_activities.editing = false

    $scope.addActivity = (index) ->
      $scope.new_extracurricular_activity = {}
      $scope.new_extracurricular_activity.editing = true
      $scope.new_extracurricular_activity = UserExtracurricularActivityService.newExtracurricularActivity($scope.student)
      $scope.new_extracurricular_activity.details = []
      $scope.new_extracurricular_activity.details.push(UserExtracurricularActivityService.newExtracurricularDetail($scope.student, $scope.selected_semester.id, null))

    $scope.cancelNewActivity = () ->
      $scope.new_extracurricular_activity.editing = false

    $scope.editActivity = (index) ->
      $scope.user_extracurricular_activities[index].editing = true
      $scope.user_extracurricular_activities[index].new_name= $scope.user_extracurricular_activities[index].name
      $scope.user_extracurricular_activities[index].details[0].new_leadership = $scope.user_extracurricular_activities[index].details[0].leadership
      $scope.user_extracurricular_activities[index].details[0].new_description = $scope.user_extracurricular_activities[index].details[0].description

    $scope.selectedActivity = (newActivity) ->
      if newActivity.name == 'Other'
        $scope.new_extracurricular_activity.newActivity = true
      $scope.new_extracurricular_activity = newActivity
      $scope.new_extracurricular_activity.editing = true
      $scope.new_extracurricular_activity.show = true
      $scope.new_extracurricular_activity.details = []
      $scope.new_extracurricular_activity.details.push(UserExtracurricularActivityService.newExtracurricularDetail($scope.student, $scope.selected_semester.id, newActivity.id))

]
