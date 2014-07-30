angular.module('myApp')
.directive('moduleProgressCircle', [function(){
  return {
    restrict: 'EA',
    scope: {
      module: '='
    },
    link: function(scope, element, attrs) {
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

      scope.render = function(module) {
          chart.selectAll("g").remove();
          chart.selectAll("text").remove();
          // Throw in a switch statement for now, try to integrate  module
          // color directive
          switch (module.module_title) {
              case 'Academics':       var moduleColor = '#41ad49'; break;
              case 'Service':         var moduleColor = '#e8be28'; break;
              case 'Extracurricular': var moduleColor = '#ef413d'; break;
              case 'College_Prep':    var moduleColor = '#27aae1'; break;
              case 'Testing':         var moduleColor = '#9665aa'; break;
          }

          var modulePoints = module.points.user;
          var totalPoints = module.points.total;
          var data = [
            {name: "Points Earned", value: (totalPoints == 0) ? 1 : modulePoints},
            {name: "Total Points", value: (totalPoints == 0) ? 0 : totalPoints - modulePoints}
          ];


          var color = d3.scale.ordinal()
              .range([moduleColor, '#191a1b']);

          var arc = d3.svg.arc()
              .outerRadius(radius)
              .innerRadius(radius - 12);

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
/*
          d3.select("#AcademicsRadio")
              .on("change", dataChange);

          function dataChange() {
              var value = this.value;
              pie.value(function(d) { return d[value]; });
              path = g.data(pie);
              path.transition().duration(850).attrTween("d", yesNoTween);
          }

          function yesNoTween(a) {
              var i = d3.interpolate(this._current, a);
              this._current = i(0);
              return function(t) {
                  return arc(i(t));
              };
          }
*/
          d3.select("#" + module.module_title).append("text")
          .attr("dy", "0.2em")
          .attr("class", "value")
          .attr("fill", "white")
          .attr("font-size", "30")
          .style("text-anchor", "middle")
          .text(function(d) {
              return modulePoints + "/" + totalPoints;});

          d3.select("#" + module.module_title).append("text")
          .attr("dy", "1.7em")
          .attr("class", "text")
          .attr("fill", "white")
          .style("text-anchor", "middle")
          .text(function(d) {
              return "points";});
      }

      scope.$watch('module', function(){
          scope.render(scope.module);
      }, true);
    }
  }
}]);
