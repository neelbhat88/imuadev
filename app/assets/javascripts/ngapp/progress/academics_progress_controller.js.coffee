angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}
    $scope.classes.editing = false

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserClassService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes
            $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
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
          $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
          $scope.classes.editing = false

          $scope.refreshPoints()

    $scope.deleteClass = (user_class) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserClassService.delete(user_class)
          .success (data) ->
            $scope.user_classes = removeClass($scope.user_classes, user_class)
            $scope.gpa = data.user_gpa.regular_unweighted.toFixed(2)
            $scope.refreshPoints()

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
