// Monkey patch the latlng object and the number classes

// extend Number object with methods for converting degrees/radians

/** Convert numeric degrees to radians */
    if (typeof(String.prototype.toRad) === "undefined") {
	Number.prototype.toRad = function() {
	    return this * Math.PI / 180;
	}
    }


google.maps.LatLng.prototype.distanceFrom = function(point, precision) {
    // default 4 sig figs reflects typical 0.3% accuracy of spherical model
    if (typeof precision == 'undefined') precision = 4;  
    if (typeof R == 'undefined') R = 6371000;  // earth's mean radius in m
    var lat1 = this.lat().toRad(), lon1 = this.lng().toRad();
    var lat2 = point.lat().toRad(), lon2 = point.lng().toRad();
    var dLat = lat2 - lat1;
    var dLon = lon2 - lon1;

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1) * Math.cos(lat2) * 
        Math.sin(dLon/2) * Math.sin(dLon/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c;
    // d.toPrecisionFixed(precision);
    return d;
}


function CanvasOverlay(bounds, map) {

    // Now initialize all properties.
    this.bounds_ = bounds;
    this.map_ = map;

    // We define a property to hold the image's
    // div. We'll actually create this div
    // upon receipt of the add() method so we'll
    // leave it null for now.
    this.div_ = null;
    this.canvas = null;

    /* Use an injected onDraw function, because:
       - We don't want to start drawing before the canvas is created.
       - We want the draw function to be called on resizes and such
    */
    this.onDraw = null;
    
    // Explicitly call setMap() on this overlay
    this.setMap(map);
}

CanvasOverlay.prototype = new google.maps.OverlayView();

CanvasOverlay.prototype.onAdd = function() {

    // Note: an overlay's receipt of onAdd() indicates that
    // the map's panes are now available for attaching
    // the overlay to the map via the DOM.

    // Create the DIV and set some basic attributes.
    var div = document.createElement('div');
    div.style.border = "none";
    div.style.borderWidth = "0px";
    div.style.position = "absolute";

    // Create an IMG element and attach it to the DIV.
    var canvas = document.createElement("canvas");
    
    // canvas.style.width = "100%";
    // canvas.style.height = "100%";
    canvas.style.opacity = "0.7";
    canvas.id = "canvas";
    div.appendChild(canvas);

    // Set the overlay's div_ property to this DIV
    this.div_ = div;
    this.canvas = canvas;
    this.scene = new Canvas(canvas);
    // We add an overlay to a map via one of the map's panes.
    // We'll add this overlay to the overlayImage pane.
    var panes = this.getPanes();
    panes.overlayLayer.appendChild(div);
}
CanvasOverlay.prototype.draw = function() {

    // Size and position the overlay. We use a southwest and northeast
    // position of the overlay to peg it to the correct position and size.
    // We need to retrieve the projection from this overlay to do this.
    var overlayProjection = this.getProjection();

    // Retrieve the southwest and northeast coordinates of this overlay
    // in latlngs and convert them to pixels coordinates.
    // We'll use these coordinates to resize the DIV.
    var swlatlng = this.bounds_.getSouthWest();
    var nelatlng = this.bounds_.getNorthEast();

    var nwlatlng = new google.maps.LatLng(nelatlng.lat(), swlatlng.lng());
    var selatlng = new google.maps.LatLng(swlatlng.lat(), nelatlng.lng());
    
    var sw = overlayProjection.fromLatLngToDivPixel(swlatlng);
    var ne = overlayProjection.fromLatLngToDivPixel(nelatlng);

    // Resize the image's DIV to fit the indicated dimensions.
    var div = this.div_;
    var canvas = this.canvas;

    // Define the number of pixels in the canvas. 
    // 1 pixel per screen pixel.
    // Maybe add a fromLatLngToCanvasCoordinate, so you can draw at different higher/lower resolution. 
    canvas.width = ne.x - sw.x;
    canvas.height = sw.y - ne.y;

    /*
    An alternative approach would be to make canvas height in meters:
    var cartesianWidth = (nwlatlng.distanceFrom(nelatlng) + swlatlng.distanceFrom(selatlng));
    var cartesianHeight = (nwlatlng.distanceFrom(swlatlng) + nelatlng.distanceFrom(selatlng));
    */
    div.style.left = sw.x + 'px';
    div.style.top = ne.y + 'px';
    div.style.width = canvas.width + 'px';
    div.style.height = canvas.height + 'px';
    
    // Make the canvast the same size as it's parent div    
    canvas.style.width = div.style.width;
    canvas.style.height =  div.style.height;

    if (this.onDraw != null)
    {
	this.onDraw(this);
    }
    
}
CanvasOverlay.prototype.onRemove = function() {
    this.div_.parentNode.removeChild(this.div_);
    this.div_ = null;
    this.canvas = null;
}

CanvasOverlay.fromLatLngToCanvasPoint = function(latlng) {

}

