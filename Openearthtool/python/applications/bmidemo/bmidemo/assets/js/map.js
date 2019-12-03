
var paths;
var svg;
var overlay;
var grid;
var size;
var s1;

// Connection to water levela updates
socket = io.connect(location.protocol + '//' + location.hostname +  ':8001');

console.log(socket);
// // Define a function that absorbs the grid
socket.on('grid', function(data) {
    console.log(data.length);
    grid = JSON.parse(data);
    size = grid.features.length;
    if (overlay != null) {
        overlay.draw();
    }
});
socket.emit('grid', {});


// Add the map
var $map = $("#map");
var map = new google.maps.Map($map[0], {
    zoom: 13,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    center: new google.maps.LatLng(51.81, 5.3532),
    styles:[{"stylers": [{"saturation": -75},{"lightness": 25}]}]
});

// Load data
overlay = new google.maps.OverlayView();

// Add the svg element
overlay.onAdd = function () {

    var layer = d3.select(this.getPanes().overlayLayer).append("div").attr("class", "SvgOverlay");
    svg = layer.append("svg").attr('class', 'svgmap');

};


overlay.draw = function () {
    if (grid == null){return;}
    svg.selectAll('.cells').remove();
    var cells = svg.append("g").attr("class", "cells");
    var markerOverlay = this;
    var overlayProjection = markerOverlay.getProjection();

    // Turn the overlay projection into a d3 projection
    var googleMapProjection = function (coordinates) {
        var googleCoordinates = new google.maps.LatLng(coordinates[1], coordinates[0]);
        var pixelCoordinates = overlayProjection.fromLatLngToDivPixel(googleCoordinates);
        return [pixelCoordinates.x + 4000, pixelCoordinates.y + 4000];
    };
    path = d3.geo.path().projection(googleMapProjection);
    paths = cells.selectAll("path")
        .data(grid.features)
        .attr("d", path) // update existing paths
        .enter().append("svg:path")
        .attr("d", path)
        .attr("id", function(x,i) {return 'cell' + x.properties.cellid;});
};

overlay.setMap(map);

setTimeout(function(x) {
    $('#ee')[0].play();
}, 10000);
socket.on('s1', function (data) {
    json = JSON.parse(data);
    s1 =json.s1;
    if (paths != null) {
        paths
            .style('fill', function(x,i){
                return d3.rgb(255*Math.max(Math.min(s1[i]/10.0,1.0),0.0),255*0.5,255*Math.max(Math.min(s1[i]/10.0,1.0),0.0)).toString();
            }
                  );
    }
});
