// initiate ge api (and variables)
var geAvailable;
var geApiLoaded = false;
var ge;
var currentKmlObject = null;
var currentGeApiDiv;

if (geAvailable==undefined)
  {
    // Google Earth was not initiated before
    geAvailable = false;
    try
      {
        google.load("earth", "1");
        geAvailable = true;
	// geApiLoaded = true;
      }
    catch(err)
      {
        geAvailable = false;
      }
  }

function initgoogle(apidivs)
{
        if (apidivs==undefined)
        {
          apidivs = currentGeApiDiv;
        }
	google.earth.setLanguage('en');

	for (i=0;i<=apidivs.length-1;i=i+1)
	  {
	    var divID = $(apidivs[i]).attr("id");
	    google.earth.createInstance(divID, initCB, failureCB);
	  }
}

function initCB(instance)
{
	ge = instance;
	ge.getWindow().setVisibility(true);

	ge.getNavigationControl().setVisibility(ge.VISIBILITY_SHOW);

	// fetch the KML
	// relative urls do not work in v5.0 --> see issue 290

	var url = currentGeApiDiv.attr("url");
	google.earth.fetchKml(ge, url, finished);
}

function finished(object)
{
if (!object)
	{
		// wrap alerts in API callbacks and event handlers
		// in a setTimeout to prevent deadlock in some browsers
		setTimeout(function() {alert('Bad or null KML.');}, 0);
		return;
	}

	ge.getFeatures().appendChild(object);
	var lookat = ge.createLookAt('');

	var longitude = parseFloat(currentGeApiDiv.attr("lon"));
	var latitude = parseFloat(currentGeApiDiv.attr("lat"));
	var rotation = parseFloat(currentGeApiDiv.attr("rot"));
	var tilt = parseFloat(currentGeApiDiv.attr("tilt"));
	var altitude = parseFloat(currentGeApiDiv.attr("alt"));

	lookat.set(longitude, latitude, 0, ge.ALTITUDE_RELATIVE_TO_GROUND, rotation, tilt, altitude);
	ge.getView().setAbstractView(lookat);
}

function failureCB(errorCode)
{
}