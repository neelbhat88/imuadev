# You must have novalidate in all forms, and place the 'imua-form'
# directive within the form element

# Must also set imua-form="controllerPostingFunction"

angular.module('myApp')
.directive 'imuaForm', ['$parse', ($parse) ->
  require: 'form'
  link: (scope, element, attrs, form) ->
    form.$submitted = false
    submitFunction = $parse(attrs.imuaForm)

    element.on('submit', (event) ->
      scope.$apply( () -> form.$submitted = true)

      if form.$valid
        submitFunction(scope, { $event : event })
        form.$submitted = false
    )
]
