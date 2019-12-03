Array.prototype.max = function() {
    return Math.max.apply(null, this);
};

Array.prototype.min = function() {
    return Math.min.apply(null, this);
};

void setup() {


    // Variables to use for plotting
    s1 = null;
    lines = null;
    grid = null;
    size = 0;
    minx = 1e100;
    maxx=-1e100;
    miny = 1e100;
    maxy=-1e100;

    isipad = navigator.userAgent.match(/iPhone|iPad|iPod/i);
    // Connection to water levela updates
    socket = io.connect(location.protocol + '//' + location.hostname +  ':8001');

    socket.on('grid', function(data) {
        grid = JSON.parse(data);
        size = grid.features.length;

        for (i=0;i<size;i++) {
            cell = grid.features[i];
            coordinates = cell.geometry.coordinates[0];
            for (j=0;j<coordinates.length;j++){
                minx=Math.min(minx, coordinates[j][0]);
                maxx=Math.max(maxx, coordinates[j][0]);
                miny=Math.min(miny, coordinates[j][1]);
                maxy=Math.max(maxy, coordinates[j][1]);
            }
        }
        console.log(minx, maxx,miny,maxy);

    });
    socket.emit('grid', {});

    socket.on('s1', function (data) {
        json = JSON.parse(data);
    });
    socket.on('lines', function(data) {
        json = JSON.parse(data);
        lines = json.lines;
    });

    // Plotting parameters
    width=500;
    height=500;
    background(0);
    frameRate(12);
    selected = 0;

    // Colors
    white = color(255, 255, 255, 255);
    green = color(0, 255, 0, 127);
    colorMode(HSB, 255);
    color c;

    // // Read grid
    // url = "/model/1/grid";
    // $.getJSON(url, function(data) {
    //         // Get the grid. (only the cells)
    //         grid = data;
    //         size = grid.cells.length;
    //     });


};

void draw() {
    if (grid == null) {
        return;
    }

    if (s1 === null) {
        return;
    }
    for (i=0;i<size;i++) {
        x = min(max(s1[i]/10.0,0.0),1.0);

        r = x*255;
        g = 126;
        b = x*255;
        c = color(r, 126, b);
        fill(c);
        noStroke();
        cell = grid.features[i];
        coordinates = cell.geometry.coordinates[0];

        x = coordinates.map(function(x){return (x[0]-minx)/(maxx-minx)*width;});
        y = coordinates.map(function(x){return (x[1]-miny)/(maxy-miny)*height;});
        if (coordinates.length==5) {
            quad(
                (coordinates[0][0]-minx)/(maxx-minx)*width,
                (coordinates[0][1]-miny)/(maxy-miny)*height,
                (coordinates[1][0]-minx)/(maxx-minx)*width,
                (coordinates[1][1]-miny)/(maxy-miny)*height,
                (coordinates[2][0]-minx)/(maxx-minx)*width,
                (coordinates[2][1]-miny)/(maxy-miny)*height,
                (coordinates[3][0]-minx)/(maxx-minx)*width,
                (coordinates[3][1]-miny)/(maxy-miny)*height
            );

            if (
                mouseX >= x.min() &&
                    mouseX < x.max() &&
                    mouseY >= y.min() &&
                    mouseY < y.max()
            ) {
                strokeWeight(2);
                stroke(white);
                quad(
                    (coordinates[0][0]-minx)/(maxx-minx)*width,
                    (coordinates[0][1]-miny)/(maxy-miny)*height,
                    (coordinates[1][0]-minx)/(maxx-minx)*width,
                    (coordinates[1][1]-miny)/(maxy-miny)*height,
                    (coordinates[2][0]-minx)/(maxx-minx)*width,
                    (coordinates[2][1]-miny)/(maxy-miny)*height,
                    (coordinates[3][0]-minx)/(maxx-minx)*width,
                    (coordinates[3][1]-miny)/(maxy-miny)*height
                );
                selected = i; //grid.cells[i].nodes[0];
            }
        }
    }
    if (lines == null || isipad) {
        return;
    };
    for (i=0;i<lines.length;i++) {
        stroke(green);
        strokeWeight(3);   // Default
        noFill();
        beginShape();
        line = lines[i];
        for (j=0;j<line.length;j++) {
            point = line[j];
            curveVertex((point[0]-minx)/(maxx-minx)*width, (point[1]-miny)/(maxy-miny)*height);
        }
        endShape();
    }


};
void mouseClicked() {
    socket.emit('set', {s1: selected});


}
