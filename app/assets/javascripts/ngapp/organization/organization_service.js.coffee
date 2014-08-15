angular.module('myApp')
.service 'OrganizationService', ['$http', '$q', ($http, $q) ->
  @all = ()->
    $http.get('/api/v1/organization')

  @getOrganizationWithRoadmap = (orgId) ->
    $http.get('api/v1/organization/' + orgId + '/info_with_roadmap')

  @getOrganizationWithUsers = (orgId) ->
    $http.get('/api/v1/organization/' + orgId + '/info_with_users')

  @getTimeUnits = (orgId) ->
    $http.get('/api/v1/organization/' + orgId + '/time_units')

  @ #  Returns 'this', otherwise it'll return the last function
]
