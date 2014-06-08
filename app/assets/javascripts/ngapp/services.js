angular.module('myApp.services', []);

angular.module('myApp.services')

.factory('OrganizationService', ['$http', '$q', function($http, $q) {

  var service = {
    all: function() {
      var defer = $q.defer();

      $http.get('/api/v1/organization')
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        });

      return defer.promise;
    },

    getOrganization: function(orgId) {
      var defer = $q.defer();

      $http.get('/api/v1/organization/' + orgId)
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        });

      return defer.promise;
    }
  };

  return service;

}]);