void setup()
{

    Array.prototype.max = function() {
        return Math.max.apply(null, this)
    }

    Array.prototype.min = function() {
        return Math.min.apply(null, this)
    }
    width=500;
    height=500;
    drawgrid = false;
    white = color(255, 255, 255, 255);
    green = color(0, 255, 0, 127);
    colorMode(HSB, 255);
    grid = null;
    // Read grid
    url = "/model/1/grid";
    $.getJSON(url, function(data) {
            // Get the grid. (only the cells)
            grid = data;
            size = grid.cells.length;
        });
    console.log(width);
    background(0);

    frameRate(15);
    selected = 0;
}


void draw(){
    // Read the bytes from the array
    url = "/model/1/variable/s1";

    // Don't replace this by $.get or $.ajax, we need an arraybuffer response
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'arraybuffer';
    xhr.onload = function(e) {
        buffer = new Uint8Array(this.response);
        data = new Float32Array(buffer.buffer);
        i=0;
        for (i=0;i<size;i++) {
            color c = color((data[i]/7)*255, 126, (data[i]/10)*255);
            fill(c);
            noStroke();
            cell = grid.cells[i];
            if (cell.x.length==4) {
                quad(
                     cell.x[0]*width,
                     cell.y[0]*height,
                     cell.x[1]*width,
                     cell.y[1]*height,
                     cell.x[2]*width,
                     cell.y[2]*height,
                     cell.x[3]*width,
                     cell.y[3]*height
                     );

                if (
                    mouseX/width >= cell.x.min() &&
                    mouseX/width < cell.x.max() &&
                    mouseY/height >= cell.y.min() &&
                    mouseY/height < cell.y.max()
                    ) {
                    selected = i; //grid.cells[i].nodes[0];
                }
            }
        }
        if (drawgrid) {
            for (i=0;i<size;i++) {
                cell = grid.cells[i];

                strokeWeight(3);
                stroke(green);
                noFill();
                quad(
                     cell.x[0]*width,
                     cell.y[0]*height,
                     cell.x[1]*width,
                     cell.y[1]*height,
                     cell.x[2]*width,
                     cell.y[2]*height,
                     cell.x[3]*width,
                     cell.y[3]*height
                     );
                strokeWeight(1);
                stroke(white);
                quad(
                     cell.x[0]*width,
                     cell.y[0]*height,
                     cell.x[1]*width,
                     cell.y[1]*height,
                     cell.x[2]*width,
                     cell.y[2]*height,
                     cell.x[3]*width,
                     cell.y[3]*height
                     );
            }
        }
        cell = grid.cells[selected];
        stroke(red);
        noFill();
        quad(
             cell.x[0]*width,
             cell.y[0]*height,
             cell.x[1]*width,
             cell.y[1]*height,
             cell.x[2]*width,
             cell.y[2]*height,
             cell.x[3]*width,
             cell.y[3]*height
             );
    }
    xhr.send();
}





void mouseClicked(event) {
    url = "/model/1/variable/s1/set/" + selected;
    $.post(url, function(data) {redraw()});
}
//     url = "/model/1/variable/s1/set/" + str(cellid);
//     var xhr = new XMLHttpRequest();
//     xhr.open('POST', url, true);
//     var float32Array = new Float32Array([value]);
//     xhr.send(float32Array);
//     noLoop();
// }
