angular.module('myApp.controllers', [])

.controller('ProfileController', ['$scope', 'SessionService', 'UsersService',
  function($scope, SessionService, UsersService) {

    $scope.user = SessionService.currentUser;
    $scope.origUser = angular.copy($scope.user)
    $scope.editingInfo = false;
    $scope.editingPassword = false;

    $scope.editing = function() {
      return $scope.editingInfo || $scope.editingPassword;
    };

    $scope.editUserInfo = function() {
      $scope.editingInfo = true;
    };

    $scope.cancelUpdateUserInfo = function() {
      $scope.files = null;
      $('.js-upload')[0].value = ""; // sort of hacky but it'll do for now
      $scope.user = angular.copy($scope.origUser);
      $scope.editingInfo = false;
      $scope.errors = {};
    };

    $scope.updateUserInfo = function() {

      var fd = new FormData();
      angular.forEach($scope.files, function(file) {
        fd.append('user[avatar]', file);
      });

      UsersService.updateUserInfoWithPicture($scope.user, fd)
      .then(
        function Success(data) {
          // ToDo: Success message here
          $scope.user = data.user;

          $scope.files = null;
          $('.js-upload')[0].value = ""; // sort of hacky but it'll do for now
          $scope.editingInfo = false;
          $scope.origUser = angular.copy($scope.user);
          $scope.errors = {};
        },
        function Error(data) {
          $scope.errors = data.info;

          // ToDo: Error message here
        }
      )
      .finally(function() {

      });

    };

    $scope.editUserPassword = function() {
      $scope.editingPassword = true;
    };

    $scope.cancelUpdatePassword = function() {
      $scope.editingPassword = false;
      clearPasswordFields();
    };

    $scope.updateUserPassword = function() {
      UsersService.updateUserPassword($scope.user, $scope.password)
        .then(
          function Success(data) {
            // ToDo: Add Success message here
            clearPasswordFields();
            $scope.editingPassword = false;
          },
          function Error(data) {
            $scope.errors = data.info;
          }
        );
    };

    function clearPasswordFields()
    {
      $scope.password = {};
      $scope.errors = {};
    }

  }

])

.controller('RoadmapController', ['$scope', 'RoadmapService', 'SessionService', '$filter',
                                  '$modal',
  function($scope, RoadmapService, SessionService, $filter, $modal)
  {
    $scope.loading = true;
    $scope.user = SessionService.currentUser;
    var orgId = -1; // TODO: Hardcoding this for now, change when organizations are added

    // This will come from the org the user is part of
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
        templateUrl: 'addMilestoneModal.html',
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
        templateUrl: 'editMilestoneModal.html',
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

.controller('AddMilestoneModalController', ['$scope', '$modalInstance', 'timeUnit',
                                            'enabledModules',
  function($scope, $modalInstance, timeUnit, enabledModules) {
    $scope.selected = {};
    $scope.errors = [];

    // Build up the dd-modules array for a dropdown
    $scope.dd_modules = [];
    $.each(enabledModules, function(index, val) {
      var moduleTitle = this.title;

      $.each(this.submodules, function(index, val) {
        var new_milestone = angular.copy(this.default_milestone);
        new_milestone.id = null;
        new_milestone.is_default = false;
        new_milestone.time_unit_id = timeUnit.id;

        $scope.dd_modules.push( { module: moduleTitle,
                                  submoduleTitle: this.title,
                                  submoduleType: this.type,
                                  templatePath: '/assets/add_' + this.type.toLowerCase() + '.html',
                                  milestone: new_milestone } );
      });
    });

    $scope.add = function()
    {
      $scope.errors = [];
      new_milestone = $scope.selected.module.milestone;

      $scope.errors = validateMilestone(timeUnit, new_milestone);

      if ($scope.errors.length == 0)
        $modalInstance.close($scope.selected.module.milestone);
    };

    $scope.cancel = function() {
      $modalInstance.dismiss('cancel');
    };

  }
])

.controller('EditMilestoneModalController', ['$scope', '$modalInstance', 'RoadmapService',
                                              'selectedMilestone', 'timeUnit',
  function($scope, $modalInstance, RoadmapService, selectedMilestone, timeUnit) {
    $scope.errors = [];
    $scope.milestone = angular.copy(selectedMilestone);

    $scope.save = function() {
      $scope.errors = [];

      $scope.errors = validateMilestone(timeUnit, $scope.milestone);

      if ($scope.errors.length == 0)
      {
        RoadmapService.updateMilestone($scope.milestone).then(
          function Success(data)
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
        RoadmapService.deleteMilestone($scope.milestone.id).then(
          function Success(data)
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
])

.controller('SuperAdminOrganizationsCtrl', ['$scope', 'SessionService', 'OrganizationService',
  function($scope, SessionService, OrganizationService) {
    var currentUser = SessionService.currentUser;

    OrganizationService.all().then(
      function Success(data) {
        $scope.organizations = data.organizations;
      }
    );
  }
])

.controller('HeaderController', ['$scope', 'SessionService',
  function($scope, SessionService) {
    $scope.user = SessionService.currentUser; // ToDo: This is null, need to figure out why
  }
]);

function validateMilestone(timeUnit, milestone)
{
  var errors = [];

  $.each(timeUnit.milestones, function(index, val) {
    if (this.id != milestone.id && (this.title == milestone.title || this.value == milestone.value))
    {
      errors.push("A milestone with the same title or value already exists in " + timeUnit.name);
      return false;
    }
  });

  return errors;
}