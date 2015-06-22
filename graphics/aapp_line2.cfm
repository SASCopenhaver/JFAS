<!--- aapp_line2.cfm --->
<!--- based on http://bl.ocks.org/mbostock --->

<!DOCTYPE html>
<meta charset="utf-8">
<style type="text/css">

svg {
  font-family: "Helvetica Neue", Helvetica;
}

.line {
  fill: none;
  stroke: #000;
  stroke-width: 2px;
}

</style>
<body>
<cfoutput>
<script language="javascript"	src="#application.paths.jsdir#jquery-1.10.2.js"></script>
<script language="javascript"	src="#application.paths.jsdir#d3.min.js"></script>
</cfoutput>
<cfinclude template="#application.paths.includes#jsGraphics.cfm">
<script>

var m = [20, 20, 30, 20],
    w = 960 - m[1] - m[3],
    h = 500 - m[0] - m[2];

var x,
    y,
    duration = 1500,
    delay = 500;

var color = d3.scale.category10();

var svg = d3.select("body").append("svg")
    .attr("width", w + m[1] + m[3])
    .attr("height", h + m[0] + m[2])
  .append("g")
    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

var stocks,
    fundtypes;

// A line generator, for the dark stroke.
var line = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(function(d) { return y(d.amt); });

// A line generator, for the dark stroke (vertical line).
var axis = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(h);

// A area generator, for the dark stroke.
var area = d3.svg.area()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y1(function(d) { return y(d.amt); });

<cfoutput>
//d3.csv("#application.urls.upload#stocks.csv", function(data) {
// data generated almost automatically from jfas
d3.csv("#application.urls.upload#stocksecp.csv", function(data) {
</cfoutput>
  // var parse = d3.time.format("%b %Y").parse;
  // jfas format for date
  var parse = d3.time.format("%Y-%m-%d").parse;

  // Nest (group) stock values by fundtype.
  fundtypes = d3.nest()
      .key(function(d) { return d.fundtype; })
      .entries(stocks = data);

  // Parse dates and numbers. We assume values are sorted by date.
  // Also compute the maximum amt per fundtype, needed for the y-domain.
  // note the plural for fundtypes
  fundtypes.forEach(function(s) {
    s.values.forEach(function(d) { d.date = parse(d.date); d.amt = +d.amt; });
    s.maxamt = d3.max(s.values, function(d) { return d.amt; });
    s.sumamt = d3.sum(s.values, function(d) { return d.amt; });
  });

  // Sort by maximum amt, descending.
  fundtypes.sort(function(a, b) { return b.maxamt - a.maxamt; });

  var g = svg.selectAll("g")
      .data(fundtypes)
    .enter().append("g")
      .attr("class", "fundtype");

  // go to next function
  setTimeout(lines, duration);
});

// ***  first graph:  lines
function lines() {
alert('lines');
  x = d3.time.scale().range([0, w - 60]);
  y = d3.scale.linear().range([h / 4 - 20, 0]);

  // Compute the minimum and maximum date across fundtypes.
  x.domain([
    d3.min(fundtypes, function(d) { return d.values[0].date; }),
    d3.max(fundtypes, function(d) { return d.values[d.values.length - 1].date; })
  ]);

  var g = svg.selectAll(".fundtype")
      .attr("transform", function(d, i) { return "translate(0," + (i * h / 4 + 10) + ")"; });

  g.each(function(d) {
    var e = d3.select(this);

    e.append("path")
        .attr("class", "line");

    e.append("circle")
        .attr("r", 5)
        .style("fill", function(d) { return color(d.key); })
        .style("stroke", "#000")
        .style("stroke-width", "2px");

    e.append("text")
        .attr("x", 12)
        .attr("dy", ".31em")
        .text(d.key);
  });

  function draw(k) {
    g.each(function(d) {
      var e = d3.select(this);
      y.domain([0, d.maxamt]);

      e.select("path")
          .attr("d", function(d) { return line(d.values.slice(0, k + 1)); });

      e.selectAll("circle, text")
          .data(function(d) { return [d.values[k], d.values[k]]; })
          .attr("transform", function(d) { return "translate(" + x(d.date) + "," + y(d.amt) + ")"; });
    });
  }

  var k = 1, n = fundtypes[0].values.length;
  d3.timer(function() {
    draw(k);
    if ((k += 2) >= n - 1) {
      draw(n - 1);
   		// go to next function
setTimeout(horizons, 500);
      return true;
    }
  });
}

// ***  next graph

function horizons() {
alert('horizons');

  svg.insert("defs", ".fundtype")
    .append("clipPath")
      .attr("id", "clip")
    .append("rect")
      .attr("width", w)
      .attr("height", h / 4 - 20);

  var color = d3.scale.ordinal()
      .range(["#c6dbef", "#9ecae1", "#6baed6"]);

  var g = svg.selectAll(".fundtype")
      .attr("clip-path", "url(#clip)");

  area
      .y0(h / 4 - 20);

  g.select("circle").transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + (w - 60) + "," + (-h / 4) + ")"; })
      .remove();

  g.select("text").transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + (w - 60) + "," + (h / 4 - 20) + ")"; })
      .attr("dy", "0em");

  g.each(function(d) {
    y.domain([0, d.maxamt]);

    d3.select(this).selectAll(".area")
        .data(d3.range(3))
      .enter().insert("path", ".line")
        .attr("class", "area")
        .attr("transform", function(d) { return "translate(0," + (d * (h / 4 - 20)) + ")"; })
        .attr("d", area(d.values))
        .style("fill", function(d, i) { return color(i); })
        .style("fill-opacity", 1e-6);

    y.domain([0, d.maxamt / 3]);

    d3.select(this).selectAll(".line").transition()
        .duration(duration)
        .attr("d", line(d.values))
        .style("stroke-opacity", 1e-6);

    d3.select(this).selectAll(".area").transition()
        .duration(duration)
        .style("fill-opacity", 1)
        .attr("d", area(d.values))
        .each("end", function() { d3.select(this).style("fill-opacity", null); });
  });

  // go to next function
  setTimeout(areas, duration + delay);
}


// ***  next graph

function areas() {
alert('areas');

  var g = svg.selectAll(".fundtype");

  axis
      .y(h / 4 - 21);

  g.select(".line")
      .attr("d", function(d) { return axis(d.values); });

  g.each(function(d) {
    y.domain([0, d.maxamt]);

    d3.select(this).select(".line").transition()
        .duration(duration)
        .style("stroke-opacity", 1)
        .each("end", function() { d3.select(this).style("stroke-opacity", null); });

    d3.select(this).selectAll(".area")
        .filter(function(d, i) { return i; })
      .transition()
        .duration(duration)
        .style("fill-opacity", 1e-6)
        .attr("d", area(d.values))
        .remove();

    d3.select(this).selectAll(".area")
        .filter(function(d, i) { return !i; })
      .transition()
        .duration(duration)
        .style("fill", color(d.key))
        .attr("d", area(d.values));
  });

  svg.select("defs").transition()
      .duration(duration)
      .remove();

  g.transition()
      .duration(duration)
      .each("end", function() { d3.select(this).attr("clip-path", null); });

  // go to next function
  setTimeout(stackedArea, duration + delay);
}


// ***  next graph

function stackedArea() {
alert('stackedArea');

  var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.date; })
      .y(function(d) { return d.amt; })
      .out(function(d, y0, y) { d.amt0 = y0; })
      .order("reverse");

  stack(fundtypes);

  y
      .domain([0, d3.max(fundtypes[0].values.map(function(d) { return d.amt + d.amt0; }))])
      .range([h, 0]);

  line
      .y(function(d) { return y(d.amt0); });

  area
      .y0(function(d) { return y(d.amt0); })
      .y1(function(d) { return y(d.amt0 + d.amt); });

  var t = svg.selectAll(".fundtype").transition()
      .duration(duration)
      .attr("transform", "translate(0,0)")
      .each("end", function() { d3.select(this).attr("transform", null); });

  t.select("path.area")
      .attr("d", function(d) { return area(d.values); });

  t.select("path.line")
      .style("stroke-opacity", function(d, i) { return i < 3 ? 1e-6 : 1; })
      .attr("d", function(d) { return line(d.values); });

  t.select("text")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (w - 60) + "," + y(d.amt / 2 + d.amt0) + ")"; });

  // go to next function
  setTimeout(streamgraph, duration + delay);
}


// ***  next graph

function streamgraph() {
alert('streamgraph');
  var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.date; })
      .y(function(d) { return d.amt; })
      .out(function(d, y0, y) { d.amt0 = y0; })
      .order("reverse")
      .offset("wiggle");

  stack(fundtypes);

  line
      .y(function(d) { return y(d.amt0); });

  var t = svg.selectAll(".fundtype").transition()
      .duration(duration);

  t.select("path.area")
      .attr("d", function(d) { return area(d.values); });

  t.select("path.line")
      .style("stroke-opacity", 1e-6)
      .attr("d", function(d) { return line(d.values); });

  t.select("text")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (w - 60) + "," + y(d.amt / 2 + d.amt0) + ")"; });

  // go to next function
  setTimeout(overlappingArea, duration + delay);
}


// ***  next graph

function overlappingArea() {
alert('overlappingArea');

  var g = svg.selectAll(".fundtype");

  line
      .y(function(d) { return y(d.amt0 + d.amt); });

  g.select(".line")
      .attr("d", function(d) { return line(d.values); });

  y
      .domain([0, d3.max(fundtypes.map(function(d) { return d.maxamt; }))])
      .range([h, 0]);

  area
      .y0(h)
      .y1(function(d) { return y(d.amt); });

  line
      .y(function(d) { return y(d.amt); });

  var t = g.transition()
      .duration(duration);

  t.select(".line")
      .style("stroke-opacity", 1)
      .attr("d", function(d) { return line(d.values); });

  t.select(".area")
      .style("fill-opacity", .5)
      .attr("d", function(d) { return area(d.values); });

  t.select("text")
      .attr("dy", ".31em")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (w - 60) + "," + y(d.amt) + ")"; });

  svg.append("line")
      .attr("class", "line")
      .attr("x1", 0)
      .attr("x2", w - 60)
      .attr("y1", h)
      .attr("y2", h)
      .style("stroke-opacity", 1e-6)
    .transition()
      .duration(duration)
      .style("stroke-opacity", 1);

  // go to next function
  setTimeout(groupedBar, duration + delay);
}


// ***  next graph

function groupedBar() {
alert('groupedBar');

  x = d3.scale.ordinal()
      .domain(fundtypes[0].values.map(function(d) { return d.date; }))
      .rangeBands([0, w - 60], .1);

  var x1 = d3.scale.ordinal()
      .domain(fundtypes.map(function(d) { return d.key; }))
      .rangeBands([0, x.rangeBand()]);

  var g = svg.selectAll(".fundtype");

  var t = g.transition()
      .duration(duration);

  t.select(".line")
      .style("stroke-opacity", 1e-6)
      .remove();

  t.select(".area")
      .style("fill-opacity", 1e-6)
      .remove();

  g.each(function(p, j) {
    d3.select(this).selectAll("rect")
        .data(function(d) { return d.values; })
      .enter().append("rect")
        .attr("x", function(d) { return x(d.date) + x1(p.key); })
        .attr("y", function(d) { return y(d.amt); })
        .attr("width", x1.rangeBand())
        .attr("height", function(d) { return h - y(d.amt); })
        .style("fill", color(p.key))
        .style("fill-opacity", 1e-6)
      .transition()
        .duration(duration)
        .style("fill-opacity", 1);
  });

  // go to next function
  setTimeout(stackedBar, duration + delay);
}


// ***  next graph

function stackedBar() {
alert('stackedBar');

  x.rangeRoundBands([0, w - 60], .1);

  var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.date; })
      .y(function(d) { return d.amt; })
      .out(function(d, y0, y) { d.amt0 = y0; })
      .order("reverse");

  var g = svg.selectAll(".fundtype");

  stack(fundtypes);

  y
      .domain([0, d3.max(fundtypes[0].values.map(function(d) { return d.amt + d.amt0; }))])
      .range([h, 0]);

  var t = g.transition()
      .duration(duration / 2);

  t.select("text")
      .delay(fundtypes[0].values.length * 10)
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (w - 60) + "," + y(d.amt / 2 + d.amt0) + ")"; });

  t.selectAll("rect")
      .delay(function(d, i) { return i * 10; })
      .attr("y", function(d) { return y(d.amt0 + d.amt); })
      .attr("height", function(d) { return h - y(d.amt); })
      .each("end", function() {
        d3.select(this)
            .style("stroke", "#fff")
            .style("stroke-opacity", 1e-6)
          .transition()
            .duration(duration / 2)
            .attr("x", function(d) { return x(d.date); })
            .attr("width", x.rangeBand())
            .style("stroke-opacity", 1);
      });

  // go to next function
  setTimeout(transposeBar, duration + fundtypes[0].values.length * 10 + delay);
}


// ***  next graph

function transposeBar() {
alert('transposeBar');

  x
      .domain(fundtypes.map(function(d) { return d.key; }))
      .rangeRoundBands([0, w], .2);

  y
      .domain([0, d3.max(fundtypes.map(function(d) { return d3.sum(d.values.map(function(d) { return d.amt; })); }))]);

  var stack = d3.layout.stack()
      .x(function(d, i) { return i; })
      .y(function(d) { return d.amt; })
      .out(function(d, y0, y) { d.amt0 = y0; });

  stack(d3.zip.apply(null, fundtypes.map(function(d) { return d.values; }))); // transpose!

  var g = svg.selectAll(".fundtype");

  var t = g.transition()
      .duration(duration / 2);

  t.selectAll("rect")
      .delay(function(d, i) { return i * 10; })
      .attr("y", function(d) { return y(d.amt0 + d.amt) - 1; })
      .attr("height", function(d) { return h - y(d.amt) + 1; })
      .attr("x", function(d) { return x(d.fundtype); })
      .attr("width", x.rangeBand())
      .style("stroke-opacity", 1e-6);

  t.select("text")
      .attr("x", 0)
      .attr("transform", function(d) { return "translate(" + (x(d.key) + x.rangeBand() / 2) + "," + h + ")"; })
      .attr("dy", "1.31em")
      .each("end", function() { d3.select(this).attr("x", null).attr("text-anchor", "middle"); });

  svg.select("line").transition()
      .duration(duration)
      .attr("x2", w);

  // go to next function
  setTimeout(donut,  duration / 2 + fundtypes[0].values.length * 10 + delay);
}


// ***  next graph

function donut() {
alert('donut');

  var g = svg.selectAll(".fundtype");

  g.selectAll("rect").remove();

  var pie = d3.layout.pie()
      .value(function(d) { return d.sumamt; });

  var arc = d3.svg.arc();

  g.append("path")
      .style("fill", function(d) { return color(d.key); })
      .data(function() { return pie(fundtypes); })
    .transition()
      .duration(duration)
      .tween("arc", arcTween);

  g.select("text").transition()
      .duration(duration)
      .attr("dy", ".31em");

  svg.select("line").transition()
      .duration(duration)
      .attr("y1", 2 * h)
      .attr("y2", 2 * h)
      .remove();

  function arcTween(d) {
    var path = d3.select(this),
        text = d3.select(this.parentNode.appendChild(this.previousSibling)),
        x0 = x(d.data.key),
        y0 = h - y(d.data.sumamt);

    return function(t) {
      var r = h / 2 / Math.min(1, t + 1e-3),
          a = Math.cos(t * Math.PI / 2),
          xx = (-r + (a) * (x0 + x.rangeBand()) + (1 - a) * (w + h) / 2),
          yy = ((a) * h + (1 - a) * h / 2),
          f = {
            innerRadius: r - x.rangeBand() / (2 - a),
            outerRadius: r,
            startAngle: a * (Math.PI / 2 - y0 / r) + (1 - a) * d.startAngle,
            endAngle: a * (Math.PI / 2) + (1 - a) * d.endAngle
          };

      path.attr("transform", "translate(" + xx + "," + yy + ")");
      path.attr("d", arc(f));
      text.attr("transform", "translate(" + arc.centroid(f) + ")translate(" + xx + "," + yy + ")rotate(" + ((f.startAngle + f.endAngle) / 2 + 3 * Math.PI / 2) * 180 / Math.PI + ")");
    };
  }

  // go to next function
  setTimeout(donutExplode, duration + delay);
}


// ***  next graph

function donutExplode() {
alert('donutExplode');

  var r0a = h / 2 - x.rangeBand() / 2,
      r1a = h / 2,
      r0b = 2 * h - x.rangeBand() / 2,
      r1b = 2 * h,
      arc = d3.svg.arc();

  svg.selectAll(".fundtype path")
      .each(transitionExplode);

  function transitionExplode(d, i) {
    d.innerRadius = r0a;
    d.outerRadius = r1a;
    d3.select(this).transition()
        .duration(duration / 2)
        .tween("arc", tweenArc({
          innerRadius: r0b,
          outerRadius: r1b
        }));
  }

  function tweenArc(b) {
    return function(a) {
      var path = d3.select(this),
          text = d3.select(this.nextSibling),
          i = d3.interpolate(a, b);
      for (var key in b) a[key] = b[key]; // update data
      return function(t) {
        var a = i(t);
        path.attr("d", arc(a));
        text.attr("transform", "translate(" + arc.centroid(a) + ")translate(" + w / 2 + "," + h / 2 +")rotate(" + ((a.startAngle + a.endAngle) / 2 + 3 * Math.PI / 2) * 180 / Math.PI + ")");
      };
    }
  }

  setTimeout(function() {
    svg.selectAll("*").remove();
    svg.selectAll("g").data(fundtypes).enter().append("g").attr("class", "fundtype");
    // return to first graph
    lines();
  }, duration);
}

</script>