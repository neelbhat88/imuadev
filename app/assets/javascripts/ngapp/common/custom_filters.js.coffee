angular.module('myApp')
.filter 'underscoresToSpaces', () ->
  (str) ->
    if typeof str != "string"
      return str
    str.replace /_/g, ' '

angular.module('myApp')
.filter 'printMilestone', () ->
  (milestone) ->
    if milestone
      if milestone.submodule == 'YesNo'
        return milestone.value
      return milestone.description + " " + milestone.value

angular.module('myApp')
.filter 'existsInArray', () ->
  (element, array) ->
    return element in array

angular.module('myApp')
.filter 'parseFloat', () ->
  (num) ->
    return parseFloat num

angular.module('myApp')
.filter 'addUnderscoreIfFirstCharIsNum', () ->
  (str) ->
    if /^\d+/.test(str)
      return "_" + str
    return str
