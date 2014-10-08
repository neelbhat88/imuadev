angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}
    $scope.classes.editing = false
    $scope.gpa_history = {}
    $scope.selected_class = null
    $scope.class_editor = false
    $scope.last_updated_gpa = null
    $scope.flexcell = 1

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserClassService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes
            if data.user_gpa
              $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
            else
              $scope.gpa = 0.toFixed(2)

            $scope.last_updated_gpa = _.last(_.sortBy($scope.student.user_classes, (u) ->
              u.updated_at)).updated_at

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

            $scope.refreshFlexcells()

            $scope.$emit('loaded_module_milestones');

    $scope.refreshFlexcells = (new_class_adder = 0) ->
      #This is probably the most inefficient way to do this, and I'm sure theres a fancy coffee/js way to do it. Feel free to replace!
      $scope.classes_length = $scope.user_classes.length + new_class_adder
      if $scope.classes_length == 1
        $scope.flexcell = "by-one"
      else
        if $scope.classes_length % 2 == 0 #even
          if $scope.classes_length % 5 == 0
            $scope.flexcell = "by-10"
          else if $scope.classes_length % 4 == 0
            $scope.flexcell = "by-4"
          else if $scope.classes_length % 3 == 0
            $scope.flexcell = "by-6"
          else
            $scope.flexcell = "by-2"
        else #odd
          if $scope.classes_length % 7 == 0
            $scope.flexcell = "by-7"
          else if $scope.classes_length % 5 == 0
            $scope.flexcell = "by-5"
          else if $scope.classes_length % 3 == 0
            $scope.flexcell = "by-3"
          else
            $scope.flexcell = "by-prime"

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
      $scope.refreshFlexcells()

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
          last_array_item = data.user_classes.length - 1
          $scope.selected_class = data.user_classes[last_array_item]
          if data.user_gpa
            $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
          else
            $scope.gpa = 0.toFixed(2)
          $scope.classes.editing = false

          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Academics')
          $scope.last_updated_gpa = new Date()

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
            $scope.last_updated_gpa = new Date()
            $scope.selected_class = null
            $scope.refreshFlexcells()

    $scope.addClass = () ->
      $scope.classes.editing = true
      new_class = UserClassService.new($scope.student, $scope.selected_semester.id)
      $scope.selected_class = new_class
      $scope.editClass(new_class)
      $scope.refreshFlexcells(1)

    $scope.cancelEdit = (user_class) ->
      if user_class.id
        user_class.editing = false
      else
        $scope.user_classes = removeClass($scope.user_classes, user_class)
        if !$scope.selected_class.id
          $scope.selectedClass(null)

      $scope.classes.editing = false
      $scope.refreshFlexcells()

    removeClass = (classes, class_to_remove) ->
      _.without(classes, _.findWhere(classes, {id: class_to_remove.id}))

    $scope.selectWidget = (widget) ->
      if $scope.selected_widget != widget
        $scope.selected_widget = widget
        $scope.selected_year = null
        $scope.selected_semester = null

    $scope.selectedClass = (user_class) ->
      if $scope.selected_class != user_class
        $scope.selected_class = user_class
        $scope.class_editor = false

]
