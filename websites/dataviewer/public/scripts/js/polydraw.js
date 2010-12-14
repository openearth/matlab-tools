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

function Polygon(lat,lon,lata,lona,sides) 
{
	var me = this;
	me.numsides = sides;
	me.cent = new PM(lat,lon,'centre','ff00ffff');
	me.rad = new PM(lata,lona,'outer','ff8080ff');
	me.setBearDist();
	var lineStringPlacemark = ge.createPlacemark('');
	me.lineString = ge.createLineString('');
	lineStringPlacemark.setGeometry(me.lineString);
	me.lineString.setTessellate(true);
	me.drawPolygon();
	ge.getFeatures().appendChild(lineStringPlacemark);
	lineStringPlacemark.setStyleSelector(ge.createStyle(''));
	me.lineStyle = lineStringPlacemark.getStyleSelector().getLineStyle();

	google.earth.addEventListener(ge.getGlobe(), "mousemove", function(event) { me.movePMLoc(event); });
	google.earth.addEventListener(ge.getGlobe(), "mousedown", function(event) { me.completelyNewLoc(event); });
}

/***********************************************************************************\
	Public Functions
\***********************************************************************************/

Polygon.prototype.setBearDist = function() 
{
	this.bear = bearing(this.cent.lat,this.cent.lon, this.rad.lat, this.rad.lon);
	this.dist = distance(this.cent.lat,this.cent.lon, this.rad.lat, this.rad.lon);
	// document.getElementById('rad').innerHTML = this.dist.toPrecision(6).toString()+' km';
	// document.getElementById('bear').innerHTML = this.bear.toDeg().toPrecision(5).toString()+' deg';
}

Polygon.prototype.setRad = function() 
{
	var latlon = destination(this.cent.lat,this.cent.lon, this.dist,this.bear);
	this.rad.setLoc (latlon[0],latlon[1]);
}

Polygon.prototype.colour = function(col) 
{
	this.lineStyle.getColor().set(col);
}

Polygon.prototype.drawPolygon = function() 
{    
	// Draw our Polygon
	var latlon;
	this.lineString.getCoordinates().clear();
	for (i=0; i <=this.numsides; i++) 
	{
		latlon = destination(this.cent.lat,this.cent.lon,this.dist,this.bear+i*2*pi/this.numsides);
		this.lineString.getCoordinates().pushLatLngAlt(latlon[0],latlon[1],0);
	}
	this.areaCircum();
}

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

PM.prototype.setLoc = function(lat,lon) 
{
	// set location of placemark.
	this.lat = lat.toRad();
	this.lon = lon.toRad();
	this.point.setLatLng(lat,lon.fixLon());
	// document.getElementById(this.name).innerHTML = lat.toPrecision(7).toString()+' , '+lon.toPrecision(7).toString();
}

Polygon.prototype.movePMLoc = function(kmlEvent) 
{
	if (!this.rad.active && !this.cent.active) 
	{
		this.colour('ffffffff');
    }
	else
	{
		kmlEvent.preventDefault(); 
		this.colour('ffc0c0c0');
		if (this.rad.active) 
		{
			this.rad.setLoc (kmlEvent.getLatitude(),kmlEvent.getLongitude());
			this.setBearDist();
			this.drawPolygon();
		}
		else
		{
			// only pick up centre placemark if vertex placemark not selected
			this.cent.setLoc (kmlEvent.getLatitude(),kmlEvent.getLongitude());
			this.setRad();
			this.drawPolygon();
		}
	}
}

Polygon.prototype.completelyNewLoc = function(kmlEvent) 
{
	if(kmlEvent.getCtrlKey())
	{
		this.cent.active = false;
		this.rad.active = true;
		this.cent.setLoc(kmlEvent.getLatitude(),kmlEvent.getLongitude());
		this.rad.setLoc(kmlEvent.getLatitude(),kmlEvent.getLongitude());
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

Polygon.prototype.areaCircum = function() 
{
	// compute area and circumference of Polygon
    var area = 0;
	var circum = 0;
	var latlon;
	if (this.numsides == 25)
	{
		// area of spherical circle = 2*pi*R^2*(1-cos(radius))
		area = 2*pi*6371*6371*(1-Math.cos(this.dist/6371));
		circum = 2*pi*6371*(Math.sin(this.dist/6371));
	}
	else if(this.numsides != 2)
	{
		// Spherical Polygon of n sides, theta is sum of internal angles: area = (theta-(n-2)*pi)*R^2                
		var latlon = destinationr(0,0,this.dist,pi);
		var latlon2 = destinationr(0,0,this.dist,pi-2*pi/this.numsides);
		var ang = 2*bearing(latlon[0],latlon[1],latlon2[0],latlon2[1]);
		area = ((this.numsides*ang)-(this.numsides-2)*pi)*6371*6371;
		circum = this.numsides*distance(latlon[0],latlon[1],latlon2[0],latlon2[1]);
	}
	// document.getElementById('per').innerHTML = circum.toPrecision(6).toString()+' km';
	// document.getElementById('are').innerHTML = area.toPrecision(8).toString()+' km<sup>2</sup>';
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
	UTILS
\***********************************************************************************/

function distance (lata,lona,latb,lonb) 
{  
	// great circle distance (km)
	return Math.acos(Math.sin(lata)*Math.sin(latb)+Math.cos(lata)*Math.cos(latb)*Math.cos(lonb-lona))*6371;
}

function bearing(lata,lona,latb,lonb) 
{  
	// initial great circle bearing (rad)
	return Math.atan2(Math.sin(lonb-lona)*Math.cos(latb), Math.cos(lata)*Math.sin(latb)-Math.sin(lata)*Math.cos(latb)*Math.cos(lonb-lona))
}

function destination(lata,lona,dist,brng) 
{
	// destination along great circle.  returns values in degrees
	var latb = Math.asin(Math.sin(lata)*Math.cos(dist/6371) + Math.cos(lata)*Math.sin(dist/6371)*Math.cos(brng));
	var lonb = lona+Math.atan2(Math.sin(brng)*Math.sin(dist/6371)*Math.cos(lata), Math.cos(dist/6371)-Math.sin(lata)*Math.sin(latb));
	return [180*latb/pi, 180*lonb/pi]
}

function destinationr(lata,lona,dist,brng) 
{ 
	// destination along great circle.  returns value in radians
	var latb = Math.asin(Math.sin(lata)*Math.cos(dist/6371) + Math.cos(lata)*Math.sin(dist/6371)*Math.cos(brng));
	var lonb = lona+Math.atan2(Math.sin(brng)*Math.sin(dist/6371)*Math.cos(lata), Math.cos(dist/6371)-Math.sin(lata)*Math.sin(latb));
	return [latb, lonb]
}

/***********************************************************************************\
	EOF
\***********************************************************************************/
