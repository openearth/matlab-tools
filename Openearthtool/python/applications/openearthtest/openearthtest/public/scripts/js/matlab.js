// Call Matlab Interpolate function
function CallMatLabInterpolate()//CallMatLabInterpolate(result)
{
	nc = "http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_water_salinity/id559-NOORDWK10.nc"
	
	var balloon = ge.createHtmlDivBalloon('');
	balloon.setFeature(pm.cent.placemark); // optional
	var div = document.createElement('DIV');
	div.innerHTML = "<a href= 'http://127.0.0.1:5000/nc_cf_stationTimeSeries/plot?"+$.param({nc:nc})+"' TARGET='_blank'><img src='http://127.0.0.1:5000/nc_cf_stationTimeSeries/plot?"+$.param({nc:nc})+"' width=200 height=200></a>";
	balloon.setContentDiv(div);
 	ge.setBalloon(balloon);	
	
	
	
	
	
	
//	if(result != null && pm.dist != 0)
//        {
//		v1=pm.rad.lat.toDeg();v2=pm.rad.lon.toDeg();
//        	c1=pm.cent.lat.toDeg();c2=pm.cent.lon.toDeg();
//        	result2 = result.split("&");
//        	n1 = result2[0];
//        	n2 = result2[1];
//        	//test = (location.href + 'interpolate/interpolate?v1='+v1+'&v2='+v2+'&c1='+c1+'&c2='+c2);
//	
//		var balloon = ge.createHtmlDivBalloon('');
//		balloon.setFeature(pm.cent.placemark); // optional
//		var div = document.createElement('DIV');
//		div.innerHTML = "<a href= 'http://127.0.0.1:5000/interpolate/interpolate?"+$.param({n1:n1,n2:n2,v1:v1,v2:v2,c1:c1,c2:c2})+"' TARGET='_blank'><img src='http://127.0.0.1:5000/interpolate/interpolate?"+$.param({n1:n1,n2:n2,v1:v1,v2:v2,c1:c1,c2:c2})+"' width=200 height=200></a>";
//		balloon.setContentDiv(div);
//	 	ge.setBalloon(balloon);
//	}
}


// Call Matlab PlotTimeSeries function
function CallMatLabPlotTimeSeries()
{
	v1 = "http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height//id1-KATWPL.nc";
	v2 = "sea_surface_height";
	v3 = "19720101T120000";
	v4 = "19730101T120000";

	var balloon = ge.createHtmlDivBalloon('');
	balloon.setFeature(pm.cent.placemark); // optional
	var div = document.createElement('DIV');
	div.innerHTML = "<a href= 'http://127.0.0.1:5000/plottimeseries/plot?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4})+"' TARGET='_blank'><img src='http://127.0.0.1:5000/plottimeseries/plot?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4})+"' width=200 height=200></a>";
	balloon.setContentDiv(div);
 	ge.setBalloon(balloon);
       	//balloon.setContentString('<img src="' + 'plottimeseries/plot' + '"/>');
       	//balloon.setContentString('<img src="' + 'plottimeseries/plot?' + $.param({v1:"http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height//id1-KATWPL.nc",v2:"sea_surface_height"})+ '"/>');
       	//test = (location.href + 'plottimeseries/plot?' + $.param({v1:"http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height//id1-KATWPL.nc",v2:"sea_surface_height"}));
       	//window.open(test,'PlotTimeSeries','width=961,height=620,scrollbars=yes,toolbar=yes,location=yes');
}

// Call Matlab Transform function
function CallMatLabTransform(date1,time1,date2,time2)
{
	c1=pm.cent.lat.toDeg();c2=pm.cent.lon.toDeg();
	v1 = date1.value; //"11/01/2009";
	v2 = time1.value; //"12/12/2009"
	v3 = date2.value; //"11/01/2009";
	v4 = time2.value; //"12/12/2009"
	v5 = c1;             
	v6 = c2;             
	//v5 = "d:/Repositories/oetools/python/applications/openearthtest/openearthtest/public/tst.asc";      
	
	test = 'http://127.0.0.1:5000/transform/transform?'+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5,v6:v6})
	window.open(test,'WaveTransformation','width=961,height=620,scrollbars=yes,toolbar=yes,location=yes')

	//test = 'http://127.0.0.1:5000/transform/transform?'+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5});
	//window.open(test,'WaveTransformation','width=961,height=620,scrollbars=yes,toolbar=yes,location=yes');
	
	//var balloon = ge.createHtmlDivBalloon('');
	//balloon.setFeature(pm.cent.placemark); // optional
	//var div = document.createElement('DIV');
	////div.innerHTML = "<a href= 'http://127.0.0.1:5000/transform/transform?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5,v6:v6})+"' TARGET=''http://127.0.0.1:5000/transform/transform?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5,v6:v6})+"''>test</a>";
	//div.innerHTML = "<a href= 'http://127.0.0.1:5000/transform/transform?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5,v6:v6})+"' TARGET='_blank'><img src='http://127.0.0.1:5000/transform/transform?"+$.param({v1:v1,v2:v2,v3:v3,v4:v4,v5:v5,v6:v6})+"' width=200 height=200></a>";
	//balloon.setContentDiv(div);
 	//ge.setBalloon(balloon);
}





// Call Matlab Multitile function
function CallMatLabMultitile()
{
	v1=pm.rad.lat.toDeg();v2=pm.rad.lon.toDeg();
        c1=pm.cent.lat.toDeg();c2=pm.cent.lon.toDeg();
        test = 'http://127.0.0.1:5000/multitile/multitile?'+$.param({v1:v1,v2:v2,c1:c1,c2:c2});
        var href = test;
	google.earth.fetchKml(ge, test, function(kmlObject) {
	      if (kmlObject)
	         ge.getFeatures().appendChild(kmlObject);
	});
        
}



