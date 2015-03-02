angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}
    $scope.classes.editing = false
    $scope.gpa_history = {}
    $scope.class_editor = false
    $scope.last_updated_gpa = null
    $scope.org_class_titles = {}
    $scope.formErrors = [ '**Please fix the errors above**' ]


    $scope.$watch 'selected_semester', () ->
      $scope.class_editor = false
      if $scope.selected_semester
        $scope.loaded_data = false
        UserClassService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes
            $scope.org_class_titles = data.org_class_titles
            if data.user_gpa
              $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
            else
              $scope.gpa = 0.toFixed(2)

            $scope.last_updated_gpa = _.last(_.sortBy($scope.student.user_classes, (u) ->
              u.updated_at)).updated_at if $scope.student.user_classes.length > 0

            date_format_gpa_history =
              _.each(data.user_gpa_history, (h) ->
                h.date_updated = moment(h.updated_at).format('MM/DD/YYYY'))

            $scope.gpa_history.values = []
            $scope.gpa_history.dates = []
            for gpa_history in data.user_gpa_history
              max_updated_at_for_day =
                _.last(_.sortBy(_.where(date_format_gpa_history, {date_updated: moment(gpa_history.updated_at).format('MM/DD/YYYY')}), (h) -> h.updated_at)).updated_at

              if gpa_history.updated_at >= max_updated_at_for_day and gpa_history.regular_unweighted != 0
                $scope.gpa_history.values.push(gpa_history.regular_unweighted)
                $scope.gpa_history.dates.push(gpa_history.date_updated)

            $scope.loaded_data = true
            $scope.$emit('loaded_module_milestones');

    $scope.editorClick = () ->
      $scope.class_editor = !$scope.class_editor

    $scope.editClass = (user_class) ->
      $scope.classes.editing = true
      user_class.editing = true
      user_class.seeAdvanced = false
      # Is there a better way to do this??
      user_class.new_name = user_class.name
      user_class.new_grade = user_class.grade
      user_class.new_grade_value = user_class.grade_value
      user_class.new_room = user_class.room
      user_class.new_period = user_class.period
      user_class.new_level = user_class.level
      user_class.new_subject = user_class.subject
      user_class.new_credit_hours = user_class.credit_hours

    $scope.editClassAdvanced = (user_class) ->
      $scope.classes.editing = true
      user_class.editing = true
      user_class.seeAdvanced = true
      # Is there a better way to do this??
      user_class.new_name = user_class.name
      user_class.new_grade = user_class.grade
      user_class.new_grade_value = user_class.grade_value
      user_class.new_room = user_class.room
      user_class.new_period = user_class.period
      user_class.new_level = user_class.level
      user_class.new_subject = user_class.subject
      user_class.new_credit_hours = user_class.credit_hours

    $scope.saveClass = (user_class) ->
      if !user_class.new_name || !user_class.new_grade
        return

      new_class = UserClassService.new($scope.student, $scope.selected_semester.id)
      new_class.id = user_class.id
      new_class.name = user_class.new_name
      new_class.grade = user_class.new_grade
      new_class.grade_value = user_class.new_grade_value
      new_class.room = user_class.new_room
      new_class.period = user_class.new_period
      new_class.level = user_class.new_level
      new_class.subject = user_class.new_subject
      new_class.credit_hours = user_class.new_credit_hours

      UserClassService.save(new_class)
        .success (data) ->
          $scope.user_classes = data.user_classes

          if data.user_gpa
            $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
          else
            $scope.gpa = 0.toFixed(2)
          $scope.classes.editing = false

          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Academics')
          $scope.last_updated_gpa = new Date()

          $scope.addSuccessMessage("Class saved successfully")

    $scope.deleteClass = (user_class, $event) ->
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
            $scope.last_updated_gpa = new Date()

            $scope.addSuccessMessage("Class deleted successfully")

      $event.stopPropagation()

    $scope.addClass = () ->
      new_class = UserClassService.new($scope.student, $scope.selected_semester.id)
      $scope.editClass(new_class)
      $scope.user_classes.push(new_class)

    $scope.toggleAdvanced = (user_class) ->
      user_class.seeAdvanced = !user_class.seeAdvanced

    $scope.cancelEdit = (user_class) ->
      if user_class.id
        user_class.editing = false
      else
        $scope.user_classes = removeClass($scope.user_classes, user_class)

      $scope.classes.editing = false

    removeClass = (classes, class_to_remove) ->
      _.without(classes, _.findWhere(classes, {id: class_to_remove.id}))

    $scope.selectWidget = (widget) ->
      if $scope.selected_widget != widget
        $scope.selected_widget = widget
        $scope.selected_year = null
        $scope.selected_semester = null

]
