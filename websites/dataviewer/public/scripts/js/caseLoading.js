// Load selected case
function loadCase(value, mode)
{
	// fill kmldata listbox
	var caseDoc = loadXMLDoc("xml/cases.xml");
	document.getElementById("case_title").innerHTML = caseDoc.getElementsByTagName("title")[value].childNodes[0].nodeValue;
	fileType = mode + "file";
	datafile = caseDoc.getElementsByTagName(fileType)[value].childNodes[0].nodeValue;
	getDataOutOfCase(datafile,mode);

	// zoom to case specific coordinates
	lon_cam = parseFloat(caseDoc.getElementsByTagName("lon")[value].childNodes[0].nodeValue);
	lat_cam = parseFloat(caseDoc.getElementsByTagName("lat")[value].childNodes[0].nodeValue);
	alt_cam = parseFloat(caseDoc.getElementsByTagName("height")[value].childNodes[0].nodeValue);

	var camera = ge.getView().copyAsCamera(ge.ALTITUDE_RELATIVE_TO_GROUND);
	camera.setLatitude(lat_cam);
	camera.setLongitude(lon_cam);
	camera.setAltitude(alt_cam);
	ge.getView().setAbstractView(camera);
}

// Fill up the data source area with datasources on the basis of the selected case
function getDataOutOfCase(xmlfile,mode)
{
	// remove all existing kml objects
	features = ge.getFeatures().getChildNodes()
	for(var i = 0; i < features.getLength(); i++)
	{
	var feat = features.item(i);
	ge.getFeatures().removeChild(feat);
	}

	// empty select lists
	while(document.getElementById("kmlForInterpolation").options.length!=0)
	document.getElementById("kmlForInterpolation").remove(0);

	// set initial polygon
	pm = new Polygon(0,0,0,0,document.getElementById('polygonselect').value);

	// load case-specific xml file
	xmlDoc=loadXMLDoc("xml/" + xmlfile);
	numOfData=xmlDoc.getElementsByTagName(mode).length;

	// create html-code of checkboxes for each kml found in the case xml and fill up the select lists
	var dataSelectText = [];

	for (i=0;i<numOfData;i=i+1)
	{
		kmlFileName = xmlDoc.getElementsByTagName(mode)[i].getElementsByTagName("kml")[0].childNodes[0].nodeValue;
		kmlTitle = xmlDoc.getElementsByTagName(mode)[i].getElementsByTagName("title")[0].childNodes[0].nodeValue;

		// checkboxes
		dataSelectText = dataSelectText + "<input type='checkbox' class='s' id='" + kmlFileName +
							"' onclick='toggleKml(this)'>" + kmlTitle + "<br>";

		currentKmlObjects[kmlFileName] = null;

		// select lists for interpolatetoline function
		if (xmlDoc.getElementsByTagName(mode)[i].getElementsByTagName("interpolatetoline").length == 1)
			{
			var oOption = document.createElement("OPTION");
			oOption.text  = kmlTitle;
			oOption.value = xmlDoc.getElementsByTagName(mode)[i].getElementsByTagName("interpolatetoline")[0].getElementsByTagName("source")[0].childNodes[0].nodeValue + "&" +
						    xmlDoc.getElementsByTagName(mode)[i].getElementsByTagName("interpolatetoline")[0].getElementsByTagName("varname")[0].childNodes[0].nodeValue;
			document.getElementById("kmlForInterpolation").options.add(oOption)
			}
	}

	document.getElementById("kml_sources").innerHTML =dataSelectText;

	// check if select lists are empty
	if (document.getElementById("kmlForInterpolation").options.length==0)
		{
			var oOption = document.createElement("OPTION");
			oOption.text="no suitable data";
			oOption.value=0;
			document.getElementById("kmlForInterpolation").options.add(oOption)
		}
}