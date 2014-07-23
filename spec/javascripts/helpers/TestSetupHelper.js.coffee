# beforeEach () ->
#   this.$controller = null
#   $rootScope = null
#   CONSTANTS = null
#   this.scope = null
#   $location = null
#   $q = null
#   $httpBackend = null
#
#   # Load the module
#   beforeEach module "myApp"
#   beforeEach inject (_$controller_, _$rootScope_, _$location_, _CONSTANTS_, _$httpBackend_) ->
#     this.$controller = _$controller_
#     $rootScope = _$rootScope_
#     $location = _$location_
#     CONSTANTS = _CONSTANTS_
#     $httpBackend = _$httpBackend_
#
#     parentScope = $rootScope.$new()
#     this.$controller "AppController", {$scope: parentScope}
#     this.scope = parentScope.$new() # Creates a new scope that's a child of parentScope
#
#   afterEach () ->
#     $httpBackend.verifyNoOutstandingExpectation()
#     $httpBackend.verifyNoOutstandingRequest()

# ****************************
# Doing this here and not in each spec file caused Jasmine to only run 1 test at a time for some reason...
# ****************************
