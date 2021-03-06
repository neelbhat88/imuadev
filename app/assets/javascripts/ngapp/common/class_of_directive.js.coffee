angular.module('myApp')
.directive 'classOfDropdown', [() ->
  restrict: 'E'
  scope: {
    model: '=',
    form: '='
  }
  link: (scope, elem, attrs) ->
    scope.class_of = [
      {name: '-- Graduating Class --', value: null},
      {name: 'Class of 2014', value: 2014},
      {name: 'Class of 2015', value: 2015},
      {name: 'Class of 2016', value: 2016},
      {name: 'Class of 2017', value: 2017},
      {name: 'Class of 2018', value: 2018},
      {name: 'Class of 2019', value: 2019},
      {name: 'Class of 2020', value: 2020},
      {name: 'Class of 2021', value: 2021}
      {name: 'Class of 2022', value: 2022}
      {name: 'Class of 2023', value: 2023}
      {name: 'Class of 2024', value: 2024}
    ]
  templateUrl: 'common/class_of_dd.html'
]
