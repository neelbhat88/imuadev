angular.module('myApp')
.directive 'modulecolor', ['CONSTANTS', (CONSTANTS) ->
    link: (scope, element, attrs) ->
      attrs.$observe 'modulecolor', (value) ->
        moduleTitle = value
        colorClass = "color--" + moduleTitle.toLowerCase()

        $(element).removeClass (index, css) ->
          return ((css.match (/\bcolor--\S+/g)) or []).join(' ')

        $(element).addClass(colorClass)
]
