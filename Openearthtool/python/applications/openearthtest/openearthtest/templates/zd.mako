<html>

<head>

	<<!-- script to generate GoogleEarth plugin -->
	<script src="https://www.google.com/jsapi?key=ABQIAAAAVqCseOYylEg-Mc5u6LZD9xQChx54JYdgbPKio935j7RDK0bGdhSP7HZfiWq_54SIgjJ1e136ihOhBw"></script>

	<script src="http://dtvirt13/bwn/optie_python/js/loadxmldoc.js" type="text/javascript"> </script>
	<script src="http://dtvirt13/bwn/optie_python/js/soapclient.js" type="text/javascript"> </script>
	<script src="http://dtvirt13/bwn/optie_python/js/polydraw.js" type="text/javascript"> </script>
	<script type="text/javascript">
		var ge = null;
		var pm = null;
		var kml = null;
		var casexml = "http://127.0.0.1:5000/zd_data.xml";

		google.load("earth", "1", {'other_params': 'sensor=false' });

		// Initialize called on HTML body load
		function init() {
			google.earth.setLanguage('en');
			google.earth.createInstance("map3d", initCallback, failureCallback);
		}

		function initCallback(object) {
			ge = object;
			ge.getWindow().setVisibility(true);

			<!-- *** Modify to suit your application *** -->
			var cam = ge.getView().copyAsCamera(ge.ALTITUDE_ABSOLUTE);
			cam.setAltitude(120000);
			cam.setLatitude(51.6);
			cam.setLongitude(4.0);
			ge.getView().setAbstractView(cam);
			ge.getNavigationControl().setVisibility(ge.VISIBILITY_SHOW);
		    // Polygon used for drawing the shape in Google Earth
		    pm = new Polygon(0,0,0,0,document.getElementById('polygonselect').value);
		    // Load the desired KML on start
			loadKML('http://dtvirt13/test/ahn100.kmz');
        	}

        	function failureCallback(object) {
        	}

		// If Google Earth fails to load this function captures the Error Code
		function failureCB(errorCode){}

		// Initialize KMLs to be shown in Google Earth (needed for export to MathLab)
		function loadKML(kmlLocation)
		{
			// If a previous KML has been loaded, unload it.
			if (kml != null)
			{
				ge.getFeatures().removeChild(kml);
			}
			// Load the KML from location
			google.earth.fetchKml(ge, kmlLocation,  function(kmlObject)
													{
														if (kmlObject)
														{
															kml = kmlObject;
															ge.getFeatures().appendChild(kmlObject);
														}
													}
			);
		}

		function loadWMS(wmsLocation)
		{
			var groundOverlay = ge.createGroundOverlay('');
			groundOverlay.setIcon(ge.createIcon(''));
			groundOverlay.getIcon().setHref(wmsLocation);
			groundOverlay.setLatLonBox(ge.createLatLonBox(''));
			var center = ge.getView().copyAsLookAt(ge.ALTITUDE_RELATIVE_TO_GROUND);
			var north = center.getLatitude() + .75;
			var south = center.getLatitude() - .75;
			var east = center.getLongitude() + 1.00;
			var west = center.getLongitude() - 1.00;
			var rotation = 0;
			var latLonBox = groundOverlay.getLatLonBox();
			latLonBox.setBox(north, south, east, west, rotation);
			ge.getFeatures().appendChild(groundOverlay);
		}

		// Call Matlab Interpolate function
		function CallMatLabInterpolate()
        {
        if(pm != 0)
        {
        //document.getElementById("inter_image").src = data;
        vertex = new Array(2);
        centre = new Array(2);
        vertex[0]=pm.rad.lat.toDeg();vertex[1]=pm.rad.lon.toDeg();
        centre[0]=pm.cent.lat.toDeg();centre[1]=pm.cent.lon.toDeg();
        v1 = vertex[0].toString();
        v2 = vertex[1].toString();
        c1 = centre[0].toString();
        c2 = centre[1].toString();
        temp = location.href;
        temp = temp.replace("zd/map", "");
        test = (temp + 'interpolate/interpolate?v1='+v1+'&v2='+v2+'&c1='+c1+'&c2='+c2);
        window.open(test,'Interpolate','width=961,height=620,scrollbars=yes,toolbar=yes,location=yes');

		//location.href = (location.href + 'interpolate/interpolate?v1='+v1+'&v2='+v2+'&c1='+c1+'&c2='+c2);
		//location.href = (location.href + '/interpolate/interpolate/'+KMLfile+'/'+vertex+'/'+centre);
		//location.href = (location.href + 'interpolate/interpolate/'+vertex+'/'+centre);
		//interpolate/interpolate?v1=51.99&v2=4.68&c1=52.15&c2=4.76
        }
		}

	</script>

	<style type="text/css">
		select.s {font-size: 10px;}
		input.vs {font-size: 8px;}
		input.s {font-size: 9px;}
	</style>

</head>

<body onload='init()' id='body'>

<div style='float:left; width:250px; height:550px; overflow:auto'>
  <table style='font-size:small'>
	<tr>
		<td>
		<form name="caseSelect" action='javascript:void(0);'>
		<p>
		<h3>Select case</h3>
		<select name="case" id="caseSelect" onchange="location.href=this.options[this.selectedIndex].value" class="s">
		<option value="/zd/map" class="vs">Zuidwestelijke Delta</option>
		<option value="/hk/map" class="vs">Hollandse Kust</option>
		<option value="/my/map" class="vs">Markermeer/IJselmeer</option>
		<option value="/si/map" class="vs">Singapore</option>
		</select>
		</p>
		</form>
		</td>
	</tr>

	<tr>
		<td>
        <form name="kmlSelect" action='javascript:void(0);'>
		<p>
		<h3>Select data</h3>
		<select name="kmlSelect" onchange='loadKML(this.value)' class="s">
		<option value="" class="vs">Select data type</option>
		// Fill in the listbox with datasources on the basis of the selected case
		<script type="text/javascript">
		xmlDoc=loadXMLDoc(casexml);
		numOfData=xmlDoc.getElementsByTagName("kml").length;
		for (i=0;i<numOfData;i=i+1)
		{
		document.write("<option value='" + xmlDoc.getElementsByTagName("kml")[i].childNodes[0].nodeValue + "' class='vs'>" + xmlDoc.getElementsByTagName("title")[i].childNodes[0].nodeValue + "</option>");
		}
		</script>
		</select>
		</p>
		</form>
		</td>
	</tr>

 	<tr>
		<td>
		<form id="polyShape" action='javascript:void(0);'>
		<p>
		<h3>Actions</h3>
		<select name="polygon" id="polygonselect" onchange='pm.numsides = this.value; pm.drawPolygon()' class="s">
			<option value="2" class="vs">Line</option>
			<option value="3" class="vs">Triangle</option>
			<option value="4" class="vs">Square</option>
			<option value="5" class="vs">Pentagon</option>
			<option value="6" class="vs">Hexagon</option>
			<option value="7" class="vs">Heptagon</option>
			<option value="8" class="vs">Octagon</option>
			<option value="9" class="vs">Nonagon</option>
			<option value="10" class="vs">Decagon</option>
			<option value="11" class="vs">Hendecagon</option>
			<option value="12" class="vs">Dodecagon</option>
			<option value="25" class="vs">Circle</option>
		</select></p>
		</form>
		</td>
	</tr>

	<tr><td>Centre: </td><td><span id='centre'></span></td></tr>
	<tr><td>Vertex: </td><td><span id='outer'></span></td></tr>
	<tr><td>Radius: </td><td><span id='rad'></span></td></tr>
	<tr><td>Bearing: </td><td><span id='bear'></span></td></tr>
	<tr><td>perimeter: </td><td><span id='per'></span></td></tr>
	<tr><td>Area: </td><td><span id='are'></span></td></tr>

	<tr>
		<td>
			<form id="interpoleButton" action='javascript:void(0);'>
				<input type="submit" name="Interpoleer" value="Interpoleer" onClick="javascript:CallMatLabInterpolate();">
			</form>
		</td>
	</tr>
</table>
<hr/>
  Drag pushpins to size, locate and rotate,<br><br>
  Crtl + mouse, moves the polygon to a new location.
</div>

<div id='map3d_container' style='border: 1px solid silver; height: 900px; margin-left:250px;'>
	<div id='map3d' style='height: 100%;'></div>
</div>

</body>

</html>