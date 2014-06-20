angular.module('myApp')
.controller('AcademicsProgressController', ['$scope', 'UserClassService',
  function($scope, UserClassService) {
    $scope.user_classes = [];
    $scope.classes = {};

    UserClassService.all($scope.current_user).success(function(data) {
      $scope.user_classes = data.user_classes;

      // Todo: Make this into a $watch on the user_classes
      $scope.gpa = UserClassService.getGPA($scope.user_classes);
    });

    $scope.saveClass = function(index) {
      var new_class = UserClassService.new($scope.current_user);
      new_class.id = $scope.user_classes[index].id;
      new_class.name = $scope.user_classes[index].new_name;
      new_class.grade = $scope.user_classes[index].new_grade;

      UserClassService.save(new_class)
        .success(function(data){
          //$scope.user_classes.splice(index, 1); // Remove this one since there is no id or other properties
          $scope.user_classes[index] = data.user_class;
          // Todo: Make this into a $watch on the user_classes
          $scope.gpa = UserClassService.getGPA($scope.user_classes);
          $scope.classes.editing = false;
        });
    }

    $scope.addClass = function() {
      $scope.classes.editing = true;
      $scope.user_classes.push(UserClassService.new($scope.current_user));
    }

    $scope.cancelEdit = function(index) {
      if ($scope.user_classes[index].id)
        $scope.user_classes[index].editing = false;
      else
        $scope.user_classes.splice(index, 1);

      $scope.classes.editing = false;
    }
  }
]);