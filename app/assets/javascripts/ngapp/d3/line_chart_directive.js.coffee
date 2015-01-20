angular.module('myApp')
.directive 'historyLineChart', [() ->
  restrict: 'EA'
  scope: {
    data: '=',
    parentclass: '@',
    identifier: '@'
  }
  link: (scope, element, attrs) ->
    d3.select(element[0]).attr("id", 'line_chart')
    setTimeout( () ->
      chart = c3.generate({
        bindto: '#line_chart',
        data: {
          json: {
            GPA: scope.data.values
          },
          types: {
            GPA: 'area'
          }
        },
        axis: {
          x: {
            type: 'category',
            categories: scope.data.dates
          }
        }
      })
    , 500)
]
