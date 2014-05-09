angular.module('myApp.controllers', [])

.controller('ProfileController', ['$scope', 'session', 'UsersService',
	function($scope, session, UsersService) {

		$scope.user = session.user;

		$scope.updateUserInfo = function() {
			
			UsersService.updateUserInfo($scope.user)
			.then(
				function(data) {
					// ToDo: Success message here
				},
				function(data) {
					$scope.user = data.user;

					// ToDo: Error message here
				}
			);

		};

	}

]);