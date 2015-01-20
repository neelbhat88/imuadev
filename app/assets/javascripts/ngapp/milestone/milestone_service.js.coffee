angular.module('myApp')
.service 'MilestoneService', ['$http', ($http) ->
  self = this

  @newMilestone = (_organization_id, _time_unit_id, _module, _submodule, _title, _description, _icon) ->
    organization_id: _organization_id,
    time_unit_id: _time_unit_id,
    module: _module,
    submodule: _submodule,
    title: _title,
    description: _description,
    icon: _icon


  @getMilestoneStatus = (milestoneId) ->
    $http.get "api/v1/milestone/#{milestoneId}/status"

  @
]
