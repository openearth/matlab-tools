(function(){



    var tileurl = "http://{s}.tile.cloudmade.com/1a1b06b230af4efdbb989ea99e9841af/998/256/{z}/{x}/{y}.png";
    var map = new L.Map("map", {
        center: [0, 180],
        zoom: 2
    });

    var background = new L.TileLayer(tileurl);

    //
    var se = L.latLng(-85.0511, -180);
    var nw = L.latLng(85.0511, 180);
    // global, so we can render to it
    canvasTiles = L.tileLayer.canvas({
        reuseTiles: true
    });
    canvasTiles.se = se;
    canvasTiles.nw = nw;

    // Add the layers
    map.addLayer(background);

    // Don't overwrite the drawtile method, draw directly from the processframe
    map.addLayer(canvasTiles);

    // Is this needed?
    map._initPathRoot()

    // Define variables for video rendering.
    var outputCanvas = document.getElementById('output'),
        output = outputCanvas.getContext('2d'),
        bufferCanvas = document.getElementById('buffer'),
        buffer = bufferCanvas.getContext('2d'),
        video = document.getElementById('video'),
        width = outputCanvas.width,
        height = outputCanvas.height,
        interval;

    function processFrame() {
        buffer.drawImage(video, 0, 0);


        // this can be done without alphaData, except in Firefox which doesn't like it when image is bigger than the canvas
        var image = buffer.getImageData(0, 0, width, height),
            imageData = image.data,
            alphaData = buffer.getImageData(0, height, width, height).data;

        // Combine image and alpha
        for (var i = 3, len = imageData.length; i < len; i = i + 4) {
            var alpha = 256-alphaData[i-1];
            // Alpha data dependend:
            // var Math.abs(imageData[i-3]-128)/2)+128+64

            imageData[i] = alpha; //Math.floor(alpha*0.7);

            // // desaturate
            // imageData[i-3] = Math.floor(Math.min(imageData[i-3]*0.5, 255));
            // // a bit more green than red
            // imageData[i-2] = Math.floor(Math.min(imageData[i-2]*0.7, 255));
            // // and a bit more blue
            // imageData[i-1] = Math.floor(Math.min(imageData[i-1]*0.9, 255));
        }


        // This is too slow
        // var color = d3.scale.linear()
        //         .domain([0, 128, 256])
        //         .range(["red", "white", "green"]);

        // for (var i = 0, len = imageData.length; i < len; i = i + 4) {
        //     var intensity = imageData[i+0],
        //         alpha = alphaData[i];

        //     // more blue
        //     var rgb = d3.rgb(color(intensity));

        //     imageData[i] = rgb.r;
        //     imageData[i+1] = rgb.g;
        //     imageData[i+2] = rgb.b;
        //     imageData[i+3] = 255-alpha;
        // }


        // This puts the data into the rendered image
        output.putImageData(image, 0, 0, 0, 0, width, height);


        // This puts the data into the rendered image
        // Loop over all the canvas tiles
        $('canvas.leaflet-tile').each(function(i, canvas){
            // Draw on ctx
            var ctx = canvas.getContext('2d');

            // Clear the tile
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            // Find the location of the tile in TMS coordinates
            var pt = canvas._tilePoint;
            // add z to pt
            canvas._layer._adjustTilePoint(pt);

            // Convert to coordinates of the output buffer
            var n = Math.pow(2, pt.z);
            // Relative coordinates
            // Round for performance
            var p = new L.Point(
                Math.round(outputCanvas.width*(pt.x/n)),
                Math.round(outputCanvas.height*(pt.y/n))
            );
            // Which part of the output canvas do we need
            var s = new L.Point(Math.round(outputCanvas.width/n) , Math.round(outputCanvas.height/n))
            // render image
            ctx.drawImage(outputCanvas,
                          p.x, p.y, s.x, s.y,
                          0, 0, canvas.width, canvas.height);
        });



    }

    video.addEventListener('play', function() {
        clearInterval(interval);
        interval = setInterval(processFrame, 50)
    }, false);



})();