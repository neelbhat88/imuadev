angular.module('myApp')
.directive('overallProgressCircle', [function(){
  return {
    restrict: 'EA',
    scope: {
      points: '='
    },
    link: function(scope, element, attrs) {
      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      var width = 68 - margin.left - margin.right;
      var height = width - margin.top - margin.bottom;

      var chart = d3.select(element[0])
              .append('svg')
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
               .append("g")
              .attr("id", "overall_progress")
              .attr("class", "overall-circle__points")
                .attr("transform", "translate(" + ((width/2)+margin.left) + "," + ((height/2)+margin.top) + ")");

      var radius = Math.min(width, height) / 2;

      scope.render = function(points) {
          chart.selectAll("g").remove();
          chart.selectAll("text").remove();

          var circleColor = '#b7b7b7';
          var userPoints = points.totalUserPoints;
          var totalPoints = points.totalPoints;
          var percentPoints = points.percentComplete;
          var data = [
            {name: "Points Earned", value: userPoints},
            {name: "Total Points", value: (totalPoints == 0) ? 1 : totalPoints - userPoints}
          ];

          var color = d3.scale.ordinal()
              .range([circleColor, '#e7e7e7']);

          var arc = d3.svg.arc()
              .outerRadius(radius)
              .innerRadius(radius - 7);

          var myScale = d3.scale.linear().domain([0, 360]).range([0, 2 * Math.PI]);

          var pie = d3.layout.pie()
              .sort(null)
              .startAngle(myScale(0))
              .endAngle(myScale(360))
              .value(function(d) { return d.value; });

          var g = chart.selectAll("path")
          .data(pie(data))
          .enter().append("g")
          .append("path").style("fill", function(d,i) { return color(i); })
              .transition()
              .duration(1300)
              .attrTween("d", tweenPie)
              .each(function(d) {this._current = d;}); // stores current angles

          function tweenPie(b) {
              var i = d3.interpolate({startAngle: myScale(0), endAngle: myScale(0)}, b);
              return function(t) {
                  return arc(i(t));
              };
          }

          d3.select("#" + "overall_progress").append("text")
          .attr("dy", "0em")
          .attr("class", "value")
          .style("text-anchor", "middle")
          .text(function(d) {
              return percentPoints + "%";});

          d3.select("#" + "overall_progress").append("text")
          .attr("dy", "1em")
          .attr("class", "text")
          .style("text-anchor", "middle")
          .text(function(d) {
              return "Complete";});
      }

      scope.$watch('points', function(){
        if (scope.points)
          scope.render(scope.points);
      }, true);
    }
  }
}]);
