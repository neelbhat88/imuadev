angular.module('myApp')
.factory('SessionService', ['$http', '$q', '$location',
  function($http, $q, $location) {

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
        if (service.isAuthenticated()) {
          return $q.when(service._currentUser);
        }
        else {
          return $http.get('/api/v1/current_user').then(function(resp){
            service._currentUser = resp.data.user;

            return service._currentUser;
          });
        }

      },

      isSuperAdmin: function() {
        return !!(service._currentUser && service._currentUser.is_super_admin)
      },

      logout: function(expired) {
        return $http.delete('/users/sign_out').then(function(resp) {
          var login_page = window.location.origin + "/login";

          if (expired)
            login_page = login_page + "?expired=true"

          console.log("Redirecting to " + login_page)
          window.location = login_page;
        });
      }

    };

    return service;
  }

]);