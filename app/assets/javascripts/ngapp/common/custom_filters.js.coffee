angular.module('myApp')
.filter 'underscoresToSpaces', () ->
  (str) ->
    if typeof str != "string"
      return str
    str.replace /_/g, ' '

angular.module('myApp')
.filter 'printMilestone', () ->
  (milestone) ->
    if milestone.submodule == 'YesNo'
      return milestone.value
    return milestone.description + " " + milestone.value
