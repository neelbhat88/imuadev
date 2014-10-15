# You must have novalidate in all forms, and place the 'imua-form'
# directive within the form element

# Must also set imua-form="controllerPostingFunction"

angular.module('myApp')
.directive 'imuaForm', ['$parse', ($parse) ->
  require: 'form'
  link: (scope, elem, attrs, form) ->
    form.$submitted = false
    submitFunction = $parse(attrs.imuaForm)

    elem.on('submit', (event) ->
      scope.$apply( () -> form.$submitted = true)

      if form.$valid
        submitFunction(scope, { $event : event })
        form.$submitted = false
    )
]

# All input fields should be wrapped in a div

angular.module('myApp')
.directive 'requiredInput', ['$compile', ($compile) ->
  require: 'ngModel',
  priority: 1000,
  link: (scope, elem, attrs, ctrl) ->
    if !elem.attr('required')
      elem.attr("required", true)
      parentDiv = $(elem).parent().closest('div')
      fieldname = attrs.name

      ngClass = "{ 'has-error': form.$submitted && form." + fieldname + ".$invalid, " + "'has-success': form.$submitted && form." + fieldname + ".$valid }"
      parentDiv.attr("ng-class", ngClass)
      alertDiv = '<div class="alert alert-danger" ng-show="form.$submitted && form.' + attrs.name + '.$error.required">This field is required</div>'
      elem.after(alertDiv)

      $compile(elem[0].form)(scope)
]
