angular.module('myApp.controllers', [])

.controller('ProfileController', ['$scope', 'session', 'UsersService',
	function($scope, session, UsersService) {

		$scope.user = session.user;
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
			$scope.user = angular.copy($scope.origUser);
			$scope.editingInfo = false;
		};

		$scope.updateUserInfo = function() {

			UsersService.updateUserInfo($scope.user)
			.then(
				function Success(data) {
					// ToDo: Success message here					
				},
				function Error(data) {
					$scope.user = data.user;

					// ToDo: Error message here
				}
			)
			.finally(function() { 
				$scope.editingInfo = false;
				$scope.origUser = angular.copy($scope.user);
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
						alert(data.info);
						clearPasswordFields();
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

]);