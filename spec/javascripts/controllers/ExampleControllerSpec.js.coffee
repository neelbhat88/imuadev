describe "ExampleController", () ->
  $controller = null
  $rootScope = null
  scope = null

  # Load the module
  beforeEach module "myApp"
  beforeEach inject (_$controller_, _$rootScope_) ->
    $controller = _$controller_
    $rootScope = _$rootScope_

    parentScope = $rootScope.$new()
    $controller "AppController", {$scope: parentScope}
    scope = parentScope.$new() # Creates a new scope that's a child of parentScope

  beforeEach () ->
    $controller "ExampleController", {$scope: scope}

  it "should set greeting", () ->
    expect(scope.greeting).toBe("Hello World")

  it "sayGreeting should return correct greeting", () ->
    expect(scope.sayGreeting()).toBe("Hello World! This works!")

# More examples below:
# http://stackoverflow.com/questions/14123306/in-angular-js-while-testing-the-controller-got-unknown-provider

# Run JS tests by typing foreman run rake jasmine in console and then going to http://localhost:8888
