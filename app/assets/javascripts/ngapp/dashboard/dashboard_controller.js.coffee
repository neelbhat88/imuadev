angular.module('myApp')
.controller "DashboardController", ["$scope", "$location", "current_user", "user",
($scope, $location, current_user, user) ->
  $scope.current_user = current_user
  if (user)
    $scope.user = user
  else
    $scope.user = current_user

  switch $scope.user.role
    when $scope.CONSTANTS.USER_ROLES.super_admin then $location.path('/sa/organizations')

  $scope.loadDashboard = (role) ->
    switch role
      when $scope.CONSTANTS.USER_ROLES.org_admin
        'dashboard/orgadmin_dashboard.html'
      # when $scope.CONSTANTS.USER_ROLES.school_admin
        # 'dashboard/schooladmin_dashboard.html'
      when $scope.CONSTANTS.USER_ROLES.mentor
        'dashboard/mentor_dashboard.html'
      when $scope.CONSTANTS.USER_ROLES.student
        'dashboard/student_dashboard.html'

]
