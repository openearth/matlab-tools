// Initialize KMLs to be shown in Google Earth (needed for export to MathLab)
function toggleKml(kml_cb)
{
	file = kml_cb.id;

    if (currentKmlObjects[file])
    {
ge.getFeatures().removeChild(currentKmlObjects[file]);
      currentKmlObject = null;
    }

	// Load the KML from location if checkbox is checked
	if (kml_cb.checked == true)
	  {
	    loadKml(file)
	   // setTimeSlider(); doen we nog maar ff niet, werkt nog niet lekker....

	  }

}

function loadKml(file)
{
    // fetch the KML
    google.earth.fetchKml(ge, file, function(kmlObject)
       {
	     if (kmlObject)
	     {
		 // show it on Earth
		 currentKmlObjects[file] = kmlObject;
		 ge.getFeatures().appendChild(kmlObject);

	     }
	     else
	     {
		 // bad KML
		 currentKmlObjects[file] = null;

		 // wrap alerts in API callbacks and event handlers in a setTimeout to prevent deadlock in some browsers
		 setTimeout(function()
		 {
		   alert('Bad or null KML.');
		 }, 0);
	 }
       });
}