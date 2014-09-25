angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}
    $scope.classes.editing = false
    $scope.gpa_history = []

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserClassService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes
            if data.user_gpa
              $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
            else
              $scope.gpa = 0.toFixed(2)

            date_format_gpa_history =
              _.each(data.user_gpa_history, (h) ->
                h.date_updated = moment(h.updated_at).format('MM/DD/YYYY'))

            for gpa_history in data.user_gpa_history
              max_updated_at_for_day =
                _.last(_.sortBy(_.where(date_format_gpa_history, {date_updated: moment(gpa_history.updated_at).format('MM/DD/YYYY')}), (h) -> h.updated_at)).updated_at

              if gpa_history.updated_at >= max_updated_at_for_day and gpa_history.regular_unweighted != 0
                $scope.gpa_history.push(gpa_history)

            $scope.$emit('loaded_module_milestones');

    $scope.editClass = (user_class) ->
      $scope.classes.editing = true
      user_class.editing = true
      # Is there a better way to do this??
      user_class.new_name = user_class.name
      user_class.new_grade = user_class.grade
      user_class.new_room = user_class.room
      user_class.new_period = user_class.period
      user_class.new_level = user_class.level
      user_class.new_subject = user_class.subject
      user_class.new_credit_hours = user_class.credit_hours

    $scope.saveClass = (user_class) ->
      new_class = UserClassService.new($scope.student, $scope.selected_semester.id)
      new_class.id = user_class.id
      new_class.name = user_class.new_name
      new_class.grade = user_class.new_grade
      new_class.room = user_class.new_room
      new_class.period = user_class.new_period
      new_class.level = user_class.new_level
      new_class.subject = user_class.new_subject
      new_class.credit_hours = user_class.new_credit_hours

      UserClassService.save(new_class)
        .success (data) ->
          index = -1
          for uc, i in $scope.user_classes
            if uc.id == user_class.id
              index = i
              break

          $scope.user_classes = data.user_classes
          if data.user_gpa
            $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
          else
            $scope.gpa = 0.toFixed(2)
          $scope.classes.editing = false

          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Academics')

    $scope.deleteClass = (user_class) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserClassService.delete(user_class)
          .success (data) ->
            $scope.user_classes = removeClass($scope.user_classes, user_class)
            if data.user_gpa
              $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
            else
              $scope.gpa = 0.toFixed(2)
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Academics')

    $scope.addClass = () ->
      $scope.classes.editing = true
      $scope.user_classes.push(UserClassService.new($scope.student, $scope.selected_semester.id))

    $scope.cancelEdit = (user_class) ->
      if user_class.id
        user_class.editing = false
      else
        $scope.user_classes = removeClass($scope.user_classes, user_class)

      $scope.classes.editing = false

    removeClass = (classes, class_to_remove) ->
      _.without(classes, _.findWhere(classes, {id: class_to_remove.id}))
]
