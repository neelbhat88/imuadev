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

.controller('RoadmapController', ['$scope', 'SessionService', 'UsersService',
	function($scope, SessionService, UsersService) {
		$scope.user = SessionService.currentUser;		
	}
])

.controller('HeaderController', ['$scope', 'SessionService',
	function($scope, SessionService) {
		$scope.user = SessionService.currentUser;	// ToDo: This is null, need to figure out why	
	}
]);