angular.module('myApp')
.directive('module-progress-circle', [function(){
  return {
    restrict: 'EA',
    scope: {
      module: '='
    },
// going to need to pass in the color based upon the module
    link: function(scope, element, attrs) {
      var data = [
        {name: "Points Earned", value: 5},
        {name: "Total Points", value: scope.module.points.total - scope.module.points.user}
      ];

      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      	width = 170 - margin.left - margin.right;
      	height = width - margin.top - margin.bottom;

      var chart = d3.select(element[0])
      				.attr("id", scope.module.title)
              .append('svg')
      			    .attr("width", width + margin.left + margin.right)
      			    .attr("height", height + margin.top + margin.bottom)
      			   .append("g")
          			.attr("transform", "translate(" + ((width/2)+margin.left) + "," + ((height/2)+margin.top) + ")");



      var radius = Math.min(width, height) / 2;

      var color = d3.scale.ordinal()
          .range(['#3FAB48', 'white']);

      var arc = d3.svg.arc()
          .outerRadius(radius)
          .innerRadius(radius - 15);

      var svg = $('#' + scope.module.title + ' svg')[0];
      var photoCircle = d3.select(svg)
                          .append("circle")
                          .attr("cx", width-85)
                          .attr("cy", height-85)
                          .attr("r", radius-20)


                //          .style("fill", "url(#photo"+scope.module.id+")");

     /* var image = d3.select(svg)
                      .append("pattern")
                      .attr("id", "photo" + scope.module.id)
                      .attr("x", 0)
                      .attr("y", 0)
                      .attr("width", 1)
                      .attr("height", 1)

      .append("image")
                       .attr("x", 0)
                      .attr("y", 0)
                      .attr("width", 130)
                      .attr("height", 130)
                      .attr("xlink:href", scope.module.square_avatar_url);

      var arc2 = d3.svg.arc().outerRadius(radius - 40);
      */

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

      g.append("path").style("fill", function(d) { return color(d.data.name); })
        .attr("d", arc);
    }
  }
}]);
