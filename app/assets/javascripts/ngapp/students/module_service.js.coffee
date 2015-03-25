angular.module('myApp')
.service 'ModuleService', [ () ->

  moduleService = this

  @selectModule = (mod) ->
    moduleService.selectedModule = mod

  return moduleService
]
