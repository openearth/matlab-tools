function draw(overlay) {
    // load json
    var projection = overlay.getProjection();
    var ctx = overlay.canvas.getContext('2d');

    var swBound = overlay.bounds_.getSouthWest();
    var neBound = overlay.bounds_.getNorthEast();

    var sw = projection.fromLatLngToDivPixel(swBound);
    var ne = projection.fromLatLngToDivPixel(neBound);

    var cake = new Canvas(overlay.canvas);
    $.getJSON("/streamtrace/move", function(json) {
	$.each(json['points'], function(index, value) {
	    var point = value;
	    var lat = point.lat[0];
	    var lon = point.lon[0];
	    var latlng = new google.maps.LatLng(lat, lon);
	    var pixel = projection.fromLatLngToDivPixel(latlng);
	    var circle = new Circle(3, {
		id: 'circle' + index,
		x: pixel.x - sw.x,
		y: pixel.y - ne.y,
		fill: 'red',
		opacity: 0.5,
		endAngle: Math.PI*2.0
	    });
	    $.each(point['lat'], function(index,value) { 
		var lat = value;
		var lon = point['lon'][index];
		var latlng = new google.maps.LatLng(lat, lon);
		var pixel = projection.fromLatLngToDivPixel(latlng);
		circle.animateTo('x', pixel.x - sw.x, index*300);
		circle.animateTo('y', pixel.y - ne.y, index*300);		
	    });
	    cake.append(circle);
	    
	})
    });
    
    for (lat=swBound.lat();lat<=neBound.lat();lat+=0.01) {
	var x1 = projection.fromLatLngToDivPixel(swBound).x - sw.x;
	var x2 = projection.fromLatLngToDivPixel(neBound).x - sw.x;
	var y1 = projection.fromLatLngToDivPixel(new google.maps.LatLng(lat,swBound.lng())).y - ne.y;
	var y2 = projection.fromLatLngToDivPixel(new google.maps.LatLng(lat,neBound.lng())).y - ne.y;
	cake.append(new Line(x1,y1,x2,y2));
    }
    
    for (lng=swBound.lng();lng<=neBound.lng();lng+=0.01) {
	var x1 = projection.fromLatLngToDivPixel(new google.maps.LatLng(swBound.lat(),lng)).x - sw.x;
	var x2 = projection.fromLatLngToDivPixel(new google.maps.LatLng(neBound.lat(),lng)).x - sw.x;
	var y1 = projection.fromLatLngToDivPixel(swBound).y - ne.y;
	var y2 = projection.fromLatLngToDivPixel(neBound).y - ne.y;
	cake.append(new Line(x1,y1,x2,y2));
    }
    

};


function initialize() {
    var latlng = new google.maps.LatLng(52.63,4.59);
    var myOptions = {
	zoom: 13,
	center: latlng,
	mapTypeId: google.maps.MapTypeId.HYBRID,
	disableDefaultUI: true
    };
    map = new google.maps.Map($('#map_canvas')[0], myOptions);
    var swBound = new google.maps.LatLng(52.61, 4.55);
    var neBound = new google.maps.LatLng(52.65, 4.63);
    var bounds = new google.maps.LatLngBounds(swBound, neBound);
    overlay = new CanvasOverlay(bounds, map);
    overlay.onDraw = function(overlay) {
	draw(overlay);
    };
};



stream = function(overlay) {
    var cake = new Canvas(overlay.canvas);

    $.getJSON("/streamtrace/trace", function(json) {
	var time = json['arrays']['IntegrationTime'];
	$.each(json['streamlines'], function(streamline_id, streamline) {
	    
	    var polygon = new Polygon(streamline,  {
		closePath:false,
		stroke:'black', 
		opacity: 0.5,
		strokeWidth: 3
	    });
	    cake.append(polygon);
	    
	    start = streamline[0];
	    start.x = start[0];
	    start.y = start[1];
	    var circle = new Circle(10, {
		id: 'streamline' + streamline_id,
		x: start.x,
		y: start.y,
		fill: 'red',
		endAngle: Math.PI*2.0
	    });
	    
	    $.each(streamline, function(time_id, position) {
		circle.animateTo('x', position[0], time[time_id]*1000.0);
		circle.animateTo('y', position[1], time[time_id]*1000.0);		
	    });
	    cake.append(circle);
	    
	});
    });
};
function initstream() {
    var latlng = new google.maps.LatLng(52.63,4.59);
    var myOptions = {
	zoom: 13,
	center: latlng,
	mapTypeId: google.maps.MapTypeId.HYBRID,
	disableDefaultUI: true
    };
    map = new google.maps.Map($('#stream_canvas')[0], myOptions);
    var swBound = new google.maps.LatLng(52.61, 4.55);
    var neBound = new google.maps.LatLng(52.65, 4.63);
    var bounds = new google.maps.LatLngBounds(swBound, neBound);
    overlay = new CanvasOverlay(bounds, map);
    overlay.onDraw = function(overlay) {
	stream(overlay);
    };
};
