angular.module('myApp')
.controller('ProgressController', ['$scope', 'current_user', 'OrganizationService', '$http',
  function($scope, current_user, OrganizationService, $http) {
    $scope.selected_module = null;
    $scope.semesters = [];

    OrganizationService.getTimeUnits(current_user.organization_id)
      .success(function(data) {
        $scope.semesters = [];
        var org_time_units = data.org_time_units;

        $.each(org_time_units, function(index, val) {
          $scope.semesters.unshift(this);

          if (current_user.time_unit_id == this.id)
            return false;
        });

        $scope.semesters[0].selected = true;
      });

    $http.post('/api/v1/progress/modules', {
              user_id: current_user.id,
              organization_id: current_user.organization_id,
              time_unit_id: current_user.time_unit_id
            })
      .success(function(data){
        $scope.modules_progress = data.modules_progress;
        $scope.selected_module = data.modules_progress[0];
      });

    $scope.selectModule = function(mod) {
      $scope.selected_module = mod;

      $.each($scope.semesters, function(index, val) {
        this.selected = false;
      });
      $scope.semesters[0].selected = true;
    }

    $scope.selectSemester = function(sem) {
      $.each($scope.semesters, function(index, val) {
        this.selected = false;

        if (this.id == sem.id)
          this.selected = true;
      });
    }
  }
]);