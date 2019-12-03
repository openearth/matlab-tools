/**********************************************\
 
	Javascript "Polygon plot" library

	Based on "polydraw" created by James Stafford

	@version : 1.1 - 27-10-2010
				
\**********************************************/

/***********************************************************************************\
	Fields
\***********************************************************************************/

var pi = Math.PI;

/***********************************************************************************\
	Constructor
\***********************************************************************************/

function Point(lat,lon) 
{
	var me = this;
	me.cent = new PM(lat,lon,'centre','ff00ffff');
	//var lineStringPlacemark = ge.createPlacemark('');
	//me.lineString = ge.createLineString('');
	//lineStringPlacemark.setGeometry(me.lineString);
	//me.lineString.setTessellate(true);
	//me.drawPoint();
	//ge.getFeatures().appendChild(lineStringPlacemark);
	//lineStringPlacemark.setStyleSelector(ge.createStyle(''));
	//me.lineStyle = lineStringPlacemark.getStyleSelector().getLineStyle();	
	
	google.earth.addEventListener(ge.getGlobe(), "mousemove", function(event) { me.cent.movePMLoc(event); });
	google.earth.addEventListener(ge.getGlobe(), "mousedown", function(event) { me.cent.completelyNewLoc(event); });
}

/***********************************************************************************\
	Public Functions
\***********************************************************************************/

function PM(lat,lon,name,colour) 
{
	// Create Placemark
	var me = this;
	me.active = false;
	me.name = name;
	me.placemark = ge.createPlacemark('');
	ge.getFeatures().appendChild(me.placemark);
	me.point = ge.createPoint('');
	me.placemark.setStyleSelector(ge.createStyle(''));
	var IconStyle = me.placemark.getStyleSelector().getIconStyle();
	IconStyle.getColor().set(colour);
	IconStyle.getHotSpot().setXUnits(ge.UNITS_FRACTION); 
	IconStyle.getHotSpot().setYUnits(ge.UNITS_FRACTION);
	IconStyle.getHotSpot().setX(0.5);
	IconStyle.getHotSpot().setY(0.5);
	me.setLoc(lat,lon);
	me.placemark.setGeometry(me.point);
	google.earth.addEventListener(me.placemark, "mousedown", function(event) { me.draw(event); });
	google.earth.addEventListener(me.placemark, "mouseup", function(event) { me.undraw(event); });
}

PM.prototype.colour = function(col) 
{
	this.lineStyle.getColor().set(col);
}

PM.prototype.drawPoint = function() 
{    
	// Draw Point
	this.lineString.getCoordinates().clear();
	this.lineString.getCoordinates().pushLatLngAlt(this.cent.lat,this.cent.lon);
}

PM.prototype.setLoc = function(lat,lon) 
{
	// set location of placemark.
	this.lat = lat.toRad(); 	
	this.lon = lon.toRad();
	this.point.setLatLng(lat,lon.fixLon());
	// document.getElementById(this.name).innerHTML = lat.toPrecision(7).toString()+' , '+lon.toPrecision(7).toString();
}


PM.prototype.movePMLoc = function(kmlEvent) 
{
	kmlEvent.preventDefault(); 
	this.colour('ffc0c0c0');
	this.setLoc (kmlEvent.getLatitude(),kmlEvent.getLongitude());
}

PM.prototype.completelyNewLoc = function(kmlEvent) 
{
	if(kmlEvent.getCtrlKey())
	{
		this.active = true;
		this.setLoc(kmlEvent.getLatitude(),kmlEvent.getLongitude());
		this.colour('ffc0c0c0');
	}
}

PM.prototype.draw = function() 
{
	this.active = true;
}

PM.prototype.undraw = function() 
{
	this.active = false;
}

Number.prototype.toRad = function() 
{
	// convert degrees to radians
	return this * pi / 180;
}

Number.prototype.toDeg = function() 
{
	// convert radians to degrees
	return this * 180 / pi;
}


Number.prototype.fixLon = function() 
{ 
	// keep longitude in range -180 to 180
	lon = this;
	while (lon < -180) {lon +=360;}
	while (lon > 180) {lon -=360;}
	return parseFloat(lon);
 
}

/***********************************************************************************\
	EOF
\***********************************************************************************/
