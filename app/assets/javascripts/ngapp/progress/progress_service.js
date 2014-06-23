angular.module('myApp')
.service('ProgressService', ['$http', function($http) {
  var self = this;

  self.getModules = function(user, time_unit_id) {
    return $http.post('/api/v1/progress/modules', {
              user_id: user.id,
              organization_id: user.organization_id,
              time_unit_id: time_unit_id
            });
  };

}]);
