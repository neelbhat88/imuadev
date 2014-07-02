angular.module('myApp')
.controller 'AcademicsProgressController', ['$scope', 'UserClassService', 'ProgressService',
  ($scope, UserClassService, ProgressService) ->
    $scope.user_classes = []
    $scope.classes = {}

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        UserClassService.all($scope.current_user, $scope.selected_semester.id)
          .success (data) ->
            $scope.user_classes = data.user_classes

    $scope.$watch 'user_classes', () ->
      $scope.gpa = UserClassService.getGPA($scope.user_classes)
    , true

    $scope.saveClass = (index) ->
      new_class = UserClassService.new($scope.current_user)
      new_class.id = $scope.user_classes[index].id
      new_class.name = $scope.user_classes[index].new_name
      new_class.grade = $scope.user_classes[index].new_grade

      UserClassService.save(new_class)
        .success (data) ->
          $scope.user_classes[index] = data.user_class
          $scope.classes.editing = false

          # ToDo: Might be better to broadcast something here that progresscontroller lisents for and then updates progress accordingly
          ProgressService.progressForModule($scope.current_user, $scope.selected_semester.id, $scope.CONSTANTS.MODULES.academics)
            .success (data) ->
              for mod in $scope.modules_progress # Loop through modules on progress controller
                if mod.module_title == data.module_progress.module_title
                  mod.points = data.module_progress.points

    $scope.deleteClass = (index) ->
      if window.confirm "Are you sure you want to delete this class?"
        UserClassService.delete($scope.user_classes[index])
          .success (data) ->
            $scope.user_classes.splice(index, 1)

    $scope.addClass = () ->
      $scope.classes.editing = true
      $scope.user_classes.push(UserClassService.new($scope.current_user))

    $scope.cancelEdit = (index) ->
      if $scope.user_classes[index].id
        $scope.user_classes[index].editing = false
      else
        $scope.user_classes.splice(index, 1)

      $scope.classes.editing = false;
]
