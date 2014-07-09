angular.module('myApp')
.directive('progressCircle', [function(){
  return {
    restrict: 'EA',
    scope: {
      myuser: '='
    },
    link: function(scope, element, attrs) {
        console.log(scope.myuser);
      var data = [
        {name: "GPA", value: Math.floor(Math.random() * 2000) + 1},
  			{name: "Extra Curricular", value:  Math.floor(Math.random() * 2000) + 1},
  			{name: "Service", value:  Math.floor(Math.random() * 2000) + 1},
  			{name: "PDUs", value:  Math.floor(Math.random() * 2000) + 1},
  			{name: "Events", value:  Math.floor(Math.random() * 2000) + 1},
        {name: "Future Progress", value: 500}
      ];

      var margin = {top: 0, right: 0, bottom: 0, left: 0};
      	width = 170 - margin.left - margin.right;
      	height = width - margin.top - margin.bottom;

      var chart = d3.select(element[0])
      				.attr("id", scope.myuser.id)
              .append('svg')
      			    .attr("width", width + margin.left + margin.right)
      			    .attr("height", height + margin.top + margin.bottom)
      			   .append("g")
          			.attr("transform", "translate(" + ((width/2)+margin.left) + "," + ((height/2)+margin.top) + ")");



      var radius = Math.min(width, height) / 2;

      var color = d3.scale.ordinal()
          .range(['#3FAB48', '#EF423C', '#FED65C', '#25AAE2', '#B160EB', 'white']);

      var arc = d3.svg.arc()
          .outerRadius(radius)
          .innerRadius(radius - 15);

      var svg = $('#' + scope.myuser.id + ' svg')[0];
      var photoCircle = d3.select(svg)
                          .append("circle")
                          .attr("cx", width-85)
                          .attr("cy", height-85)
                          .attr("r", radius-20)


                          .style("fill", "url(#photo"+scope.myuser.id+")");

      var image = d3.select(svg)
                      .append("pattern")
                      .attr("id", "photo" + scope.myuser.id)
                      .attr("x", 0)
                      .attr("y", 0)
                      .attr("width", 1)
                      .attr("height", 1)

      .append("image")
                       .attr("x", 0)
                      .attr("y", 0)
                      .attr("width", 130)
                      .attr("height", 130)
                      .attr("xlink:href", scope.myuser.square_avatar_url);

      var arc2 = d3.svg.arc().outerRadius(radius - 40);

      var myScale = d3.scale.linear().domain([0, 360]).range([0, 2 * Math.PI]);

      var pie = d3.layout.pie()
          .sort(null)
          .startAngle(myScale(45))
          .endAngle(myScale(405))
          .value(function(d) { return d.value; });

      var g = chart.selectAll(".arc")
      .data(pie(data))
      .enter().append("g")
        .attr("class", "arc");

      g.append("path").attr("fill", function(d, i) { return color(i); })
          .transition()
              .ease("bounce")
              .duration(2400)
              .attrTween("d", tweenPie);

      function tweenPie(b) {
          var i = d3.interpolate({startAngle: myScale(45), endAngle: myScale(45)}, b);
          return function(t) {
              return arc(i(t));
          };
      }
    }
  }
}]);
