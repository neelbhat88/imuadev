angular.module('myApp')
.controller 'ServiceProgressController', ['$scope', 'UserServiceOrganizationService', 'ProgressService',
  ($scope, UserServiceOrganizationService, ProgressService) ->
    $scope.user_service_organizations = []
    $scope.semester_service_hours = 0
    $scope.loaded_data = false

    $scope.resetNewServiceEntry = () ->
      if $scope.selected_semester
        $scope.new_service_organization = UserServiceOrganizationService.newServiceOrganization($scope.student)
        $scope.new_service_organization.hours.push(UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, null))
        $scope.new_service_organization.editing = false

    $scope.editNewServiceEntry = () ->
      $scope.new_service_organization.editing = true

    $scope.resetNewServiceEntry()

    $scope.$watch 'user_service_organizations', () ->
      $scope.loaded_semester_service_hours = false
      $scope.semester_service_hours = 0
      for organization in $scope.user_service_organizations
        if organization.hours
          for hour in organization.hours
            if hour.hours
              $scope.semester_service_hours += parseFloat hour.hours
      $scope.loaded_semester_service_hours = true
    , true

    $scope.$watch 'selected_semester', () ->
      if $scope.selected_semester
        $scope.resetNewServiceEntry()
        $scope.loaded_data = false
        UserServiceOrganizationService.all($scope.student.id, $scope.selected_semester.id)
          .success (data) ->
            $scope.org_current_organization_list = data.org_service_organization_titles
            $scope.user_service_organizations = data.user_service_organizations

            for user_service_organization in $scope.user_service_organizations
              user_service_organization.hours = []
              user_service_organization.non_current_hours = []
              for user_service_hour in data.user_service_hours
                if user_service_organization.id == user_service_hour.user_service_organization_id
                  if user_service_hour.time_unit_id == $scope.selected_semester.id
                    user_service_organization.hours.push(user_service_hour)
                  else
                    user_service_organization.non_current_hours.push(user_service_hour)

            $scope.loaded_data = true
            $scope.$emit('loaded_module_milestones')

    $scope.getServiceOrganizationTotalHours = (service_organization) ->
      total_hours = 0
      _.each(service_organization.hours, (h) -> total_hours += parseFloat h.hours)
      return total_hours

    $scope.serviceOrganizationIsSavable = (service_organization) ->
      return service_organization.name

    $scope.serviceHourIsSavable = (service_hour) ->
      return service_hour.description &&
             service_hour.hours &&
             service_hour.date

    $scope.newServiceEntryIsSavable = () ->
      return $scope.serviceOrganizationIsSavable($scope.new_service_organization) &&
             $scope.serviceHourIsSavable($scope.new_service_organization.hours[0])

    $scope.applicableServiceOrganizations = () ->
      return _.filter($scope.user_service_organizations, (o) -> o.hours.length > 0)


    $scope.saveNewServiceEntry = () ->
      if !$scope.newServiceEntryIsSavable()
        return

      if _.contains(_.pluck($scope.user_service_organizations, 'name'), $scope.new_service_organization.name)
        existing_organization = _.find($scope.user_service_organizations, (o) -> o.name == $scope.new_service_organization.name)
        $scope.new_service_organization.hours[0].user_service_organization_id = existing_organization.id
        UserServiceOrganizationService.saveServiceHour($scope.new_service_organization.hours[0])
          .success (data) ->
            existing_organization.hours.push(data.user_service_hour)

            $scope.resetNewServiceEntry()
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Service')
      else
        UserServiceOrganizationService.saveNewServiceOrganization($scope.new_service_organization)
          .success (data) ->
            data.user_service_organization.hours = []
            data.user_service_organization.non_current_hours = []
            data.user_service_organization.hours.push(data.user_service_hour)
            $scope.user_service_organizations.push(data.user_service_organization)
            $scope.org_current_organization_list.push(data.user_service_organization.name)

            $scope.resetNewServiceEntry()
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Service')


    $scope.editOrganization= (service_organization) ->
      service_organization.editing = true
      service_organization.new_name = service_organization.name

    $scope.cancelEditOrganization = (service_organization) ->
      service_organization.editing = false

    $scope.saveOrganization = (service_organization) ->
      if !$scope.serviceOrganizationIsSavable(service_organization)
        return

      new_service_organization = UserServiceOrganizationService.newServiceOrganization($scope.student)
      new_service_organization.id = service_organization.id
      new_service_organization.name = service_organization.new_name
      UserServiceOrganizationService.saveServiceOrganization(new_service_organization)
        .success (data) ->
          service_organization.name = data.user_service_organization.name
          service_organization.editing = false

          if !_.contains($scope.org_current_organization_list, service_organization.name)
            $scope.org_current_organization_list.push(service_organization.name)

          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Service')

    $scope.deleteOrganization = (service_organization) ->
      if window.confirm "Are you sure you want to delete this organization?"
        UserServiceOrganizationService.deleteServiceOrganization(service_organization, $scope.selected_semester.id)
          .success (data) ->
            service_organization.hours = []
            if service_organization.non_current_hours.length == 0
              $scope.user_service_organizations.splice(_.indexOf($scope.user_service_organizations, service_organization), 1)
            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Service')

    $scope.addHour= (service_organization) ->
      service_hour = UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, service_organization.id)
      service_hour.editing = true
      service_organization.hours.push(service_hour)

    $scope.saveHour = (service_hour) ->
      new_service_hour = UserServiceOrganizationService.newServiceHour($scope.student, $scope.selected_semester.id, service_hour.user_service_organization_id)
      new_service_hour.id = service_hour.id
      new_service_hour.description = service_hour.new_description
      new_service_hour.hours = service_hour.new_hours
      new_service_hour.date = service_hour.new_date

      if !$scope.serviceHourIsSavable(new_service_hour)
        return

      UserServiceOrganizationService.saveServiceHour(new_service_hour)
        .success (data) ->
          service_hour.description = data.user_service_hour.description
          service_hour.hours = data.user_service_hour.hours
          service_hour.date = data.user_service_hour.date
          service_hour.editing = false
          $scope.refreshPoints()
          $scope.$emit('just_updated', 'Service')

    $scope.editHour = (service_hour) ->
      service_hour.editing = true
      service_hour.new_description = service_hour.description
      service_hour.new_hours = service_hour.hours
      service_hour.new_date = service_hour.date

    $scope.cancelEditHour= (service_organization, service_hour) ->
      if !service_hour.id
        service_organization.hours.splice(_.indexOf(service_organization.hours, service_hour), 1)
      else
        service_hour.editing = false

    $scope.deleteHour = (service_organization, service_hour) ->
      if window.confirm "Are you sure you want to delete this hour?"
        UserServiceOrganizationService.deleteServiceHour(service_hour)
          .success (data) ->
            service_organization.hours.splice(_.indexOf(service_organization.hours, service_hour), 1)
            if service_organization.hours.length == 0 && service_organization.non_current_hours.length == 0
              $scope.user_service_organizations.splice(_.indexOf($scope.user_service_organizations, service_organization), 1)

            $scope.refreshPoints()
            $scope.$emit('just_updated', 'Service')

    $scope.editingServiceOrganization = (service_organization) ->
      return _.some(service_organization.hours, (h) -> h.editing == true) ||
             service_organization.editing == true


]
