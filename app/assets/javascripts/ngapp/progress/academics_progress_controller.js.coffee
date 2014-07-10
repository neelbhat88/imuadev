angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserClassService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes
            $scope.loaded_user_classes = true

        ProgressService.yesNoMilestones($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
          .success (data) ->
            $scope.yes_no_milestones = data.yes_no_milestones
            $scope.loaded_yes_no_milestones = true

    $scope.$watch 'user_classes', () ->
      $scope.gpa = UserClassService.getGPA($scope.user_classes)
    , true

    $scope.saveClass = (index) ->
      new_class = UserClassService.new($scope.student)
      new_class.id = $scope.user_classes[index].id
      new_class.name = $scope.user_classes[index].new_name
      new_class.grade = $scope.user_classes[index].new_grade

      UserClassService.save(new_class)
        .success (data) ->
          $scope.user_classes[index] = data.user_class
          $scope.classes.editing = false

          $scope.refreshPoints()

    $scope.deleteClass = (index) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserClassService.delete($scope.user_classes[index])
          .success (data) ->
            $scope.user_classes.splice(index, 1)
            $scope.refreshPoints()

    $scope.addClass = () ->
      $scope.classes.editing = true
      $scope.user_classes.push(UserClassService.new($scope.student))

    $scope.cancelEdit = (index) ->
      if $scope.user_classes[index].id
        $scope.user_classes[index].editing = false
      else
        $scope.user_classes.splice(index, 1)

      $scope.classes.editing = false;
]
