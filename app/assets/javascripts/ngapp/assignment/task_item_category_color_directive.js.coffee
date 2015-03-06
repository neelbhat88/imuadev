angular.module('myApp')
.directive "taskItemCategoryColor", [() ->
  restrict: 'A',
  scope: {
    assignment: '='
  }
  link: (scope, elem, attrs) ->

    if scope.assignment and scope.assignment.assignment_owner_type == "Milestone"
      bgColor = '#808080'
      switch scope.assignment.milestone.module
        when "Academics"        then bgColor = '#41e6b2'
        when "Service"          then bgColor = '#e8be28'
        when "Extracurricular"  then bgColor = '#ef6629'
        when "College_Prep"     then bgColor = '#27aae1'
        when "Testing"          then bgColor = '#9665aa'

      elem.css('background-color', bgColor)
]
