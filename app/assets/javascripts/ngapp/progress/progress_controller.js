angular.module('myApp')
.controller('ProgressController', ['$scope', 'current_user', 'OrganizationService', 'ProgressService',
  function($scope, current_user, OrganizationService, ProgressService) {
    $scope.selected_module = null;
    $scope.semesters = [];
    $scope.current_user = current_user;
    $scope.selected_semester = null;

    OrganizationService.getTimeUnits(current_user.organization_id)
      .success(function(data) {
        $scope.semesters = [];
        var org_time_units = data.org_time_units;

        // Set up each semester in descending order
        $.each(org_time_units, function(index, val) {
          $scope.semesters.unshift(this);

          if (current_user.time_unit_id == this.id)
          {
            this.name = "Current";
            return false;
          }
        });

        $scope.selected_semester = $scope.semesters[0];
      });

    ProgressService.getModules(current_user, current_user.time_unit_id)
      .success(function(data){
        $scope.modules_progress = data.modules_progress;
        $scope.selected_module = data.modules_progress[0];
      });

    $scope.selectModule = function(mod) {
      $scope.selected_module = mod;
      $scope.selected_semester = $scope.semesters[0];

      // This is super hacky since this function is injected on the tmpl.html file, but it'll do for now.
      // Put this in a attr directive e.g. 'Resize' or something
      setTimeout(function(){ setHeight(); }, 100);
    }

    $scope.selectSemester = function(sem) {
      ProgressService.getModules(current_user, sem.id)
      .success(function(data){
        $scope.modules_progress = data.modules_progress;

        // This is super hacky since this function is injected on the tmpl.html file, but it'll do for now.
        // Put this in a attr directive e.g. 'Resize' or something
        setHeight();
      });

      $scope.selected_semester = sem;
    }

    $scope.getModuleTemplate = function(modTitle) {
      if (modTitle)
        return '/assets/progress/' + modTitle.toLowerCase() + '_progress.tmpl.html';
    }
  }
]);
