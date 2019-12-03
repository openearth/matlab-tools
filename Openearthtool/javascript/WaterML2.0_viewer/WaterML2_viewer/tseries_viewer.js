function createTSeries(chartLocation) {
  formatter = function(d,i) {
    // d = value
    // i = tick index (undefined in case of label)
    var fmt;
    if (typeof i == "undefined" || i == 0) {
       fmt = "%-e %b %Y %H:%M:%S";
    } else {
       fmt = "%H:%M:%S";
    }
    var date = new Date(d);
    return d3.time.format(fmt)(date);
  }

  chart = nv.models.lineWithFocusChart();

  chart.transitionDuration(500);
  chart.xAxis
      .tickFormat(formatter);
  chart.x2Axis
      .axisLabel('Time')
      .tickFormat(formatter);

  chart.yAxis
      .tickFormat(d3.format(',.2f'));
  chart.y2Axis
      .tickFormat(d3.format(',.2f'));
  chart.margin({left: 90, right: 60});
  //chart.showLegend(false);

  d3.select(chartLocation)
      .datum(data)
      .call(chart);

  nv.utils.windowResize(chart.update);

  return chart;
};


function updateTSeries(tseries){
  chart.yAxis.axisLabel(tseries.quantity+' ('+tseries.unit+')');
  //chart.y2Axis.axisLabel(tseries.quantity+' ('+tseries.unit+')');

  data[0].key = tseries.location;
  
  data[0].values[0].x = tseries.times[0];
  data[0].values[0].y = tseries.values[0];
  for (i = 1; i<tseries.times.length; i++) {
    data[0].values.push({
      x: tseries.times[i],
      y: tseries.values[i]
    });
  }

  chart.update();
};
