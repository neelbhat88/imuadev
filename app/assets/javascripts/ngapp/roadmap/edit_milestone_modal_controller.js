angular.module('myApp')
.controller('EditMilestoneModalController', ['$scope', '$modalInstance', 'RoadmapService',
                                              'selectedMilestone', 'timeUnit',
  function($scope, $modalInstance, RoadmapService, selectedMilestone, timeUnit) {
    $scope.errors = [];
    $scope.milestone = angular.copy(selectedMilestone);

    $scope.save = function() {
      $scope.errors = [];

      $scope.errors = RoadmapService.validateMilestone(timeUnit, $scope.milestone);

      if ($scope.errors.length == 0)
      {
        RoadmapService.updateMilestone($scope.milestone).success(
          function (data)
          {
            angular.copy(data.milestone, selectedMilestone);

            $modalInstance.close();
          }
        );
      }
    };

    $scope.cancel = function() {
      $modalInstance.dismiss('cancel');
    };

    $scope.delete = function() {
      if (window.confirm("Are you sure you want to delete this milestone?"))
      {
        RoadmapService.deleteMilestone($scope.milestone.id).success(
          function (data)
          {
            $.each(timeUnit.milestones, function(index, val) {
              if (this.id == $scope.milestone.id)
              {
                timeUnit.milestones.splice(index, 1);
                return false;
              }
            });

            $modalInstance.close();
          }
        );
      }
    }
  }
]);
