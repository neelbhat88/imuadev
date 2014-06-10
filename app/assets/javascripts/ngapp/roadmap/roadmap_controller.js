angular.module('myApp')
.controller('RoadmapController', ['$scope', '$modal', 'current_user',
                                  'RoadmapService', 'LoadingService',
  function($scope, $modal, current_user, RoadmapService, LoadingService)
  {
    $scope.loading = true;
    $scope.user = current_user;
    var orgId = $scope.user.organization_id == null ? -1 : $scope.user.organization_id;

    RoadmapService.getRoadmap(orgId).then(
      function Success(data) {
        $scope.roadmap = data.roadmap;
        $scope.loading = false;
      },
      function Error(data) {
      }
    );

    RoadmapService.getEnabledModules(orgId).then(
      function Success(data) {
        $scope.enabled_modules = data.enabled_modules;
      }
    );

    $scope.createRoadmap = function(name, $event) {
      $scope.errors = [];

      if (!name)
      {
        $scope.errors.push("Your roadmap has to have a name.");
        return;
      }

      LoadingService.buttonStart($event.currentTarget);
      RoadmapService.createRoadmap(orgId, name).then(
        function Success(data) {
          $scope.roadmap = data.roadmap;
        },
        function Error(data) {
          $scope.errors = [];
          $scope.errors.push(data.info);
        }
      )
      .finally(function(){
        LoadingService.buttonStop();
      });
    }

    $scope.addTimeUnit = function(timeUnit) {
      $scope.addingTimeUnit = true;
      if (timeUnit && timeUnit.id)
      {
        timeUnit.original = angular.copy(timeUnit);
        timeUnit.editing = true;
      }
      else
      {
        var newTimeUnit = { name: "", editing: true };
        $scope.roadmap.time_units.push(newTimeUnit);
      }
    };

    $scope.saveAddTimeUnit = function(timeUnit) {
      if (!timeUnit.name)
        return;

      if (timeUnit.id) {
        RoadmapService.updateTimeUnit(timeUnit).then(
          function Success(data) {
            timeUnit.editing = false;
            $scope.addingTimeUnit = false;
          }
        )
      }
      else {
        RoadmapService.addTimeUnit(-1, $scope.roadmap.id, timeUnit).then(
          function Success(data){
            // Remove the temp object and push the newly added one on
            $scope.roadmap.time_units.pop();
            $scope.roadmap.time_units.push(data.time_unit);

            $scope.addingTimeUnit = false;
          },
          function Error(data){}
        );
      }

    };

    $scope.cancelAddTimeUnit = function(timeUnit) {
      if (timeUnit.id) // Editing an existing time_unit
      {
        timeUnit.editing = false;
        timeUnit.name = timeUnit.original.name;
      }
      else
      {
        $scope.roadmap.time_units.pop();
      }

      $scope.addingTimeUnit = false;
    };

    $scope.deleteTimeUnit = function(timeUnit)
    {
      if (window.confirm("Are you sure? Deleting this will delete all milestones within it also."))
      {
        RoadmapService.deleteTimeUnit(timeUnit.id).then(
          function Success(data)
          {
            $.each($scope.roadmap.time_units, function(index) {
              if ($scope.roadmap.time_units[index].id == timeUnit.id)
              {
                $scope.roadmap.time_units.splice(index, 1);
                $scope.addingTimeUnit = false;
                return false;
              }
            });
          }
        );
      }
    };

    $scope.addMilestone = function(timeUnit)
    {
      var modalInstance = $modal.open({
        templateUrl: '/assets/roadmap/add_milestone_modal.tmpl.html',
        controller: 'AddMilestoneModalController',
        backdrop: 'static',
        resolve: {
          timeUnit: function() {
            return timeUnit;
          },
          enabledModules: function() {
            return $scope.enabled_modules;
          }
        }
      });

      modalInstance.result.then(function (milestone){
        RoadmapService.addMilestone(milestone).then(
          function Success(data)
          {
            timeUnit.milestones.push(data.milestone);
          }
        );
      });
    },

    $scope.viewMilestone = function(timeUnit, milestone)
    {
      var modalInstance = $modal.open({
        templateUrl: '/assets/roadmap/edit_milestone_modal.tmpl.html',
        controller: 'EditMilestoneModalController',
        backdrop: 'static',
        resolve: {
          selectedMilestone: function() {
            return milestone;
          },
          timeUnit: function() {
            return timeUnit;
          }
        }
      });

      modalInstance.result.then(function (){
      });
    },

    $scope.getMilestoneClass = function(milestone)
    {
      switch(milestone.module){
      case "Academics":
        return "js-tu__milestone--academics";
      case "Service":
        return "js-tu__milestone--service";
      }

      return "";
    }

  }
])