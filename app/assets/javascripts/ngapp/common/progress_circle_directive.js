angular.module('myApp')
.directive('progressCircle', [function(){
  return {
    restrict: 'EA',
    scope: {
      student: '=',
      identifier: '@'
    },
    link: function(scope, element, attrs) {
      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      var width = 170 - margin.left - margin.right;
      var height = width - margin.top - margin.bottom;

      var chart = d3.select(element[0])
      				.attr("id", scope.student.id + "_" + scope.identifier)
              .append('svg')
      			    .attr("width", width + margin.left + margin.right)
      			    .attr("height", height + margin.top + margin.bottom)
                .attr("id", "svg" + scope.student.id + "_" + scope.identifier)
      			   .append("g")
          			.attr("transform", "translate(" + ((width/2)+margin.left) + "," + ((height/2)+margin.top) + ")");

      var radius = Math.min(width, height) / 2;

      scope.render = function(student) {
        chart.selectAll("g").remove();
        d3.select("#svg" + student.id + "_" + scope.identifier + " circle").remove();
        d3.select("#svg" + student.id + "_" + scope.identifier + " pattern").remove();

        var color = d3.scale.ordinal()
            .range(['#41e6b2', '#e8be28', '#ef6629', '#27aae1', '#9665aa', '#808080']);

        var total_points = 0;
        var user_points = 0;
        var data = [6];
        data[0] = {name: "Academics",       value: 0};
        data[1] = {name: "Service",         value: 0};
        data[2] = {name: "Extracurricular", value: 0};
        data[3] = {name: "College_Prep",    value: 0};
        data[4] = {name: "Testing",         value: 0};
        data[5] = {name: "Future Progress", value: 0};

        var _ref = student.modules_progress;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          var index = -1;
          switch (_ref[_i].module_title) {
              case 'Academics':       index = 0; break;
              case 'Service':         index = 1; break;
              case 'Extracurricular': index = 2; break;
              case 'College_Prep':    index = 3; break;
              case 'Testing':         index = 4; break;
          }
          data[index] = {name: _ref[_i].module_title, value: _ref[_i].points.user};
          user_points += _ref[_i].points.user;
          total_points += _ref[_i].points.total;
        }
        data[5] = {name: "Future Progress", value: (total_points == 0) ? 1 : total_points - user_points};

        var arc = d3.svg.arc()
            .outerRadius(radius)
            .innerRadius(radius - 14);

        var svg = $('#' + student.id + '_' + scope.identifier + ' svg')[0];
        var photoCircle = d3.select(svg)
                            .append("circle")
                            .attr("cx", width/2)
                            .attr("cy", height/2)
                            .attr("r", radius-20)


                            .style("fill", "url(#photo"+student.id+")");

        var image = d3.select(svg)
                        .append("pattern")
                        .attr("id", "photo" + student.id)
                        .attr("x", 0)
                        .attr("y", 0)
                        .attr("width", 1)
                        .attr("height", 1)

        .append("image")
                         .attr("x", 0)
                        .attr("y", 0)
                        .attr("width", width-40)
                        .attr("height", height-40)
                        .attr("xlink:href", student.square_avatar_url);

        var arc2 = d3.svg.arc().outerRadius(radius - 40);

        var myScale = d3.scale.linear().domain([0, 360]).range([0, 2 * Math.PI]);

        var pie = d3.layout.pie()
            .sort(null)
            .startAngle(myScale(0))
            .endAngle(myScale(360))
            .value(function(d) { return d.value; });

        var g = chart.selectAll(".arc")
        .data(pie(data))
        .enter().append("g")
          .attr("class", "arc");

        g.append("path").attr("fill", function(d, i) { return color(i); })
            .transition()
                .duration(800)
                .attrTween("d", tweenPie);

        function tweenPie(b) {
            var i = d3.interpolate({startAngle: myScale(0), endAngle: myScale(0)}, b);
            return function(t) {
                return arc(i(t));
            };
        }
      }

      scope.$watch('student', function() {
          scope.render(scope.student);
      }, true);
    }
  }
}]);
