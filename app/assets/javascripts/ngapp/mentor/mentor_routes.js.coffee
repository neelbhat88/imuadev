angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/mentor/:id',
    templateUrl: 'mentor/mentor.html',
    controller: 'MentorController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

      user: ['$q', '$route', 'UsersService', ($q, $route, UsersService) ->
        defer = $q.defer()

        UsersService.getUser($route.current.params.id)
          .success (data) ->
            defer.resolve(data.user)

          .error (data) ->
            defer.reject()

        defer.promise
      ]

      assigned_students: ['$q', '$route', 'UsersService', 'ProgressService',
      ($q, $route, UsersService, ProgressService) ->
        defer = $q.defer()
        assigned_students = []

        UsersService.getAssignedStudents($route.current.params.id)
        .success (data) ->
          for student in data.students
            ProgressService.getAllModulesProgress(student, student.time_unit_id).then (student_with_modules_progress) ->
              assigned_students.unshift(student_with_modules_progress)

          defer.resolve(assigned_students)

        defer.promise
      ]
]
