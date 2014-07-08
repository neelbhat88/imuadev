angular.module('myApp')
.directive('moduleProgressCircle', [function(){
  return {
    restrict: 'EA',
    scope: {
      module: '='
    },
    link: function(scope, element, attrs) {
      // Throw in a switch statement for now, try to integrate  module
      // color directive
      switch (scope.module.module_title) {
          case 'Academics':
              var moduleColor = '#41ad49';
              break;
          case 'Service':
              var moduleColor = '#e8be28';
              break;
          case 'Extracurricular':
              var moduleColor = '#ef413d';
              break;
          case 'College_Prep':
              var moduleColor = '#27aae1';
              break;
          case 'Testing':
              var moduleColor = '#9665aa';
              break;
      }

      var modulePoints = scope.module.points.user;
      var totalPoints = scope.module.points.total;
      var data = [
        {name: "Points Earned", value: (totalPoints == 0) ? 1 : modulePoints},
        {name: "Total Points", value: totalPoints - modulePoints}
      ];

      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      	width = 170 - margin.left - margin.right;
      	height = width - margin.top - margin.bottom;

      var chart = d3.select(element[0])
              .append('svg')
      			    .attr("width", width + margin.left + margin.right)
      			    .attr("height", height + margin.top + margin.bottom)
      			   .append("g")
      				.attr("id", scope.module.module_title)
      				.attr("class", "module-circle__points")
          			.attr("transform", "translate(" + ((width/2)+margin.left) + "," + ((height/2)+margin.top) + ")");



      var radius = Math.min(width, height) / 2;


      var color = d3.scale.ordinal()
          .range([moduleColor, 'white']);

      var arc = d3.svg.arc()
          .outerRadius(radius)
          .innerRadius(radius - 15);

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

      g.append("path").style("fill", function(d,i) { return color(i); })
          .transition()
          .ease("bounce")
          .duration(2000)
          .attrTween("d", tweenPie);

      function tweenPie(b) {
          var i = d3.interpolate({startAngle: myScale(0), endAngle: myScale(0)}, b);
          return function(t) {
              return arc(i(t)); };
      }

      d3.select("#" + scope.module.module_title).append("text")
      .attr("dy", "0em")
      .attr("class", "value")
      .style("text-anchor", "middle")
      .text(function(d) {
          return modulePoints + "/" + totalPoints;});

      d3.select("#" + scope.module.module_title).append("text")
      .attr("dy", "1em")
      .attr("class", "text")
      .style("text-anchor", "middle")
      .text(function(d) {
          return "points";});
      }
  }
}]);
