angular.module('myApp')
.service 'OrganizationService', ['$http', '$q', ($http, $q) ->
  @all = ()->
    $http.get('/api/v1/organization'); 

  @getOrganization = (orgId) ->
    $http.get('/api/v1/organization/' + orgId);

  @getTimeUnits = (orgId) ->
    $http.get('/api/v1/organization/' + orgId + '/time_units');

  @ #  Returns 'this', otherwise it'll return the last function
]
