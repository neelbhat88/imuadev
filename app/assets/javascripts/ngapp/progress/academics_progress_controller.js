angular.module('myApp')
.controller('AcademicsProgressController', ['$scope', function($scope){
  $scope.user_classes = [{name: "Math", grade: "A+"}, {name: "History", grade: "B"}];
}]);