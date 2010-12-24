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
