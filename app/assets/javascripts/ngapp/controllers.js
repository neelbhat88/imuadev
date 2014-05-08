angular.module('myApp.controllers', [])

.controller('ProfileController', ['$scope', 'session', 'UsersService', 'SessionService',
	function($scope, session, UsersService, SessionService) {

		$scope.user = session.user;

		$scope.updateUserInfo = function() {
			
			UsersService.updateUserInfo()
			.then(function(data){
				var newUser = {
					email: "nbhat@",
					first_name: "Neel"
				};

				$scope.user = newUser;
			});

		};

	}

]);