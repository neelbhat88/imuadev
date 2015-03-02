# Accordion directive
# Usage:
#  <div imua-accordion>
#     <div accordion-header></div>
#     <div accordion-body></div>
#     <div accordion-header></div>
#     <div accordion-body></div>
#  </div>
# The body needs to be a sibing of header, but does not have to be an immediate
# sibling. This only affects the headers and bodies within the imua-accordion
# group.

angular.module('myApp')
.directive 'accordionHeader', [
  () ->
    restrict: 'A'
    link: (scope, elem, attrs) ->
      delay = 150
      clicks = 0
      timer = null
      $(elem).click () ->
        clicks++
        if clicks == 1
          timer = setTimeout( () ->
            this_accordion = $(elem).closest('div[imua-accordion]')
            all_bodies = this_accordion.find('div[accordion-body]')
            my_body = $(elem).nextAll('div[accordion-body]')
            scope.show = !my_body.is(":visible")

            all_bodies.hide()

            if scope.show
              my_body.show()

            clicks = 0
          , delay)
        else
          clearTimeout(timer)
          clicks = 0


]

angular.module('myApp')
.directive 'accordionBody', [
  () ->
    restrict: 'A'
    link: (scope, elem, attrs) ->
      $(elem).hide()
]

angular.module('myApp')
.directive 'collapseAccordion', [
  () ->
    restrict: 'A'
    link: (scope, elem, attrs) ->
      $(elem).click () ->
        accordion_id = "#" + attrs.collapseAccordion
        $(accordion_id).find('div[accordion-body]').hide()
]
