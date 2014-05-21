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
			$('.upload')[0].value = ""; // sort of hacky but it'll do for now
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
					$('.upload')[0].value = ""; // sort of hacky but it'll do for now
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
	function($scope, RoadmapService, SessionService, $filter) {
		$scope.user = SessionService.currentUser;
		// This will come from the org the user is part of
		RoadmapService.getRoadmap(-1).then(
			function Success(data) {
				$scope.roadmap = data.roadmap;
			},
			function Error(data) {
			}
		);

		$scope.addTimeUnit = function(tu) {
			if (tu && tu.id)
			{
				tu.original = angular.copy(tu);
				tu.editing = true;
			}
			else 
			{
				var newTimeUnit = { name: "", editing: true };
				$scope.roadmap.time_units.push(newTimeUnit);
			}
		};

		$scope.saveAddTimeUnit = function(tu) {
			if (!tu.name)
				return;			

			if (tu.id) {
				RoadmapService.updateTimeUnit(tu).then(
					function Success(data) {
						tu.editing = false;
					}
				)
			}
			else {
				RoadmapService.addTimeUnit(-1, $scope.roadmap.id, tu).then(
					function Success(data){
						// Remove the temp object and push the newly added one on
						$scope.roadmap.time_units.pop();
						$scope.roadmap.time_units.push(data.time_unit);
					},
					function Error(data){}
				);
			}

		};

		$scope.cancelAddTimeUnit = function(tu) {
			if (tu.id) // Editing an existing time_unit
			{
				tu.editing = false;
				tu.name = tu.original.name;
			}
			else
			{
				$scope.roadmap.time_units.pop();
			}
		};

		$scope.deleteTimeUnit = function(tu) 
		{
			if (window.confirm("Are you sure? Deleting this will delete all milestones within it also.")) 
			{			
				RoadmapService.deleteTimeUnit(tu.id).then(
					function Success(data) 
					{
						$.each($scope.roadmap.time_units, function(index) {
							if ($scope.roadmap.time_units[index].id == tu.id)
							{
								$scope.roadmap.time_units.splice(index, 1);
								return false;
							}								
						});
					}
				)
			}
		};

		$scope.addMilestone = function(tu)
		{
			alert("Patience " + $scope.user.first_name + "! This is coming next. You can add, remove and edit time units for now.");
		}

	}
])

.controller('HeaderController', ['$scope', 'SessionService',
	function($scope, SessionService) {
		$scope.user = SessionService.currentUser;	// ToDo: This is null, need to figure out why	
	}
]);