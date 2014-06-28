angular.module('myApp')
.directive 'modulecolor', ['CONSTANTS', (CONSTANTS) ->
    link: (scope, element, attrs) ->
      attrs.$observe 'modulecolor', (value) ->
        module = value
        colorClass = ""
        colorArray = ["color--academics", "color--service"]

        switch module
          when CONSTANTS.MODULES.academics then colorClass = "color--academics"          
          when CONSTANTS.MODULES.service then colorClass = "color--service"

        $(element).removeClass(colorArray.join(" "))
        $(element).addClass(colorClass)
]