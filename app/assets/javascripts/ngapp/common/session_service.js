angular.module('myApp')
.factory('SessionService', ['$http', '$q', '$rootScope',
  function($http, $q, $rootScope) {

    var service = {

      _currentUser: null,

      isAuthenticated: function() {
        return !!service._currentUser;
      },

      isAuthorized: function(authorizedRoles) {
        if (!angular.isArray(authorizedRoles))
          authorizedRoles = [authorizedRoles];

        return ( service.isAuthenticated() &&
               authorizedRoles.indexOf(service._currentUser.role) !== -1 )
      },

      getCurrentUser: function(){
          return $http.get('/api/v1/current_user').then(function(resp){
            service._currentUser = resp.data.user;

            return service._currentUser;
          }, function(err) {console.log("Error")});

      },

      isSuperAdmin: function() {
        return !!(service._currentUser && service._currentUser.is_super_admin)
      },

      destroy: function() {
        return $http.delete('/users/sign_out').then(function(resp){
          $rootScope.$broadcast("loggedout");
        });
      }

    };

    return service;
  }

]);
