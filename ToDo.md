# To Do's

1. Remove extra defers on all HTTP calls

1. Cache Roadmap object in Angular so that it doesn't always make the rest call - Maybe cache more objects in services

1. **Tests** -> add , only: [:edit] to resources :users and see if test fails

1. Misc
  1. Status messages
  1. Loading gif
  1. If info not updated then redirect to update info page


# DEBT and QUESTIONS
- UsersController -> How to correctly send a 401 Unauthorized if the authenciate_user! fails in the application controller
Â
# Tech Talk with Greg
1. RSPEC Tests - Good tutorials? I couldn't figure out easily how to mock an ActiveRecord call. How do they do this? Controller tests are important
1. Loading gif in Angular - Is using $interceptor the best way? spin kit and Greg GIST: gist.github.com/vdub/, CSS loading
1. Access and Authorization in Angular - Using authorizedRolse and onChangeStart to do access (prevent students from accessing org admin's pages).
But on a page that both mentors and OA's can see, how to let one role do something while other role can't in a directive vs doing a bunch of ng-ifs?
1. Cache busting with Angular templates. Can I see this happening locally? Is this a solution? (https://github.com/pitr/angular-rails-templates)

### General questions
1. Do they like Intercom? Itercom is awesome, segment.io for analytics is a must!, angularitics, mixpanel
1. Where does he get design/UX inspiration? Any good design/UX resources?
1. CoffeeScript return @ at the bottom of all services (return this)

# Angular Questions
1. HOW TO DO RSPEC TESTS?? Any good tutorials? Took forever to figure out how to mock an ActiveRecord call (see roadmap_repository_rspec.rb) and just gave up

1. Understand CSRF security with   before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

1. users_service.js methods returning just $http and then using .success() and .error() with the server returning error status --> Is this a good way to do it?

1. Angular best practices for authorization (Admin only can see this page, etc)
   roles and permissions

1. Full angular header with different links for different people

1. Caching objects between pages, e.g. Roadmap can be cached after the first time you go to the roadmap page until the user refreshes their screen. Are there best practices around this?

1. ~~Page load blip~~ --> ng-cloak

1. ~~Roadmap.html~~

    ng-incude with a string built up reloads full page
    In roadmap.html See (http://lostechies.com/gabrielschenker/2013/12/28/angularjspart-6-templates/)

    ```html
    <div ng-show="selected.module" class="milestone ptl" ng-include="'/assets/add_'+selected.module.submoduleType.toLowerCase()+'.html'">
    ```
    but ```ng-include="'/assets/add_academics_gpa.html'"``` works just fine


# Don't forget
1. **Tests!**
1. Cache busting with Angular templates. Is this a solution? (https://github.com/pitr/angular-rails-templates)
