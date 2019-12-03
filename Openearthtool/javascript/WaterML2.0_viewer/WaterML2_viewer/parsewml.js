function parseWaterML2(xmlDoc){
  var json = $.xml2json(xmlDoc);
  console.log(json);

  var observation = json.observationMember.OM_Observation;

  /*
  The following line assumes that
  1) there is only one observation data set in the file
  */
  var point = observation.result.MeasurementTimeseries.point;

  /*
  The following line assumes that
  1) the observation member points to the sampling feature list
  2) there is only one monitoring point in the list
  3) it has a name
  */
  var location = json.samplingFeatureMember.MonitoringPoint['name'];

  /*
  The following lines assume that
  1) the quantity name is stored as an xlink:title
  2) the unit is stored as default data point metadate
  */
  var quantity = observation.observedProperty['xlink:title'];
  var unit = observation.result.MeasurementTimeseries.defaultPointMetadata.DefaultTVPMeasurementMetadata.uom['code'];

  /*
  The following lines assume that
  1) there are no missing data values
  2) the file doesn't use an equidistant time specification
  */
  var times = [];
  var values = [];
  for (i = 0; i<point.length; i++) {
    times[i] = Date.parse(point[i].MeasurementTVP.time);
    values[i] = Number(point[i].MeasurementTVP.value);
  };

  var tseries = {quantity:quantity, unit:unit, location:location, times:times, values:values};
  return tseries;
};
