angular.module('myApp')
.controller "DashboardController", ["$scope", "current_user",
($scope, current_user) ->
  $scope.current_user = current_user

  $scope.loadDashboard = (role) ->
    switch role
      # when $scope.CONSTANTS.USER_ROLES.org_admin
        # 'dashboard/orgadmin_dashboard.html'
      # when $scope.CONSTANTS.USER_ROLES.school_admin
        # 'dashboard/schooladmin_dashboard.html'
      when $scope.CONSTANTS.USER_ROLES.mentor
        'dashboard/mentor_dashboard.html'
      # when $scope.CONSTANTS.USER_ROLES.student
        # 'dashboard/student_dashboard.html'

]
