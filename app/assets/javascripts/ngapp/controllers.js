angular.module('myApp.controllers', [])

.controller('ProfileController', 
	function($scope, session, UsersService) {

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

);