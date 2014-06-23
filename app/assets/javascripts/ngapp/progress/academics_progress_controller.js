angular.module('myApp')
.controller('AcademicsProgressController', ['$scope', 'UserClassService',
  function($scope, UserClassService) {
    $scope.user_classes = [];
    $scope.classes = {};

    $scope.$watch('selected_semester', function(){
      UserClassService.all($scope.current_user, $scope.selected_semester.id).success(function(data) {
        $scope.user_classes = data.user_classes;
      });
    });

    $scope.$watch('user_classes', function() {
      $scope.gpa = UserClassService.getGPA($scope.user_classes);
    });

    $scope.saveClass = function(index) {
      var new_class = UserClassService.new($scope.current_user);
      new_class.id = $scope.user_classes[index].id;
      new_class.name = $scope.user_classes[index].new_name;
      new_class.grade = $scope.user_classes[index].new_grade;

      UserClassService.save(new_class)
        .success(function(data){
          $scope.user_classes[index] = data.user_class;
          $scope.classes.editing = false;
        });
    }

    $scope.deleteClass = function(index) {
      if (window.confirm("Are you sure you want to delete this class?"))
      {
        UserClassService.delete($scope.user_classes[index])
          .success(function(data) {
            $scope.user_classes.splice(index, 1);
          });
      }
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
