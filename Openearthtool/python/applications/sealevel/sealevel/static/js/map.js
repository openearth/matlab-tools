var df = null;

$(function(x) {var tileurl = "http://{s}.tile.cloudmade.com/1a1b06b230af4efdbb989ea99e9841af/998/256/{z}/{x}/{y}.png";
        var map = new L.Map("map", {
            center: [53, 3],
            zoom: 5
        })
                .addLayer(new L.TileLayer(tileurl));
        map._initPathRoot()

        var mapsvg = d3.select("#map").select("svg");
        var mapg = mapsvg.append("g").attr("class", "leaflet-zoom-hide").attr("id", "mapg");

        // Should also be set in style sheet
        var width = 450;
        var height = 550;
        var margin = 0;
        var color = ["#0b0", "#b00"]

        var plotsvg = d3.select("#plot")
                .append("svg")
                .attr("viewBox", "0 0 450 550")
                .attr("id", "plotsvg")
                .attr("preserveAspectRatio", "none")
                .append("g")
                .attr("transform", "translate(" + margin + "," + margin +")" );
        var plotg = plotsvg
                .append("g")
                .attr("id","plotg");


        // scales and axes
        var xscale = d3.scale.linear().range([0, width]);
        var yscale = d3.scale.linear().range([height, 0]);
        xscale.domain([1800, 2020]).nice();
        yscale.domain([-2000, 2000]).nice();
        var xAxis = d3.svg.axis().scale(xscale).ticks(4).tickSubdivide(true)
        var yAxis = d3.svg.axis().scale(yscale).ticks(4).orient("right");


        colorscale  = d3.scale.linear().domain([-10,0,10]).range(["#080", "#880","#800"]);

        d3.json("static/data/psmsl.json", function(collection) {

            df = collection;
            collection.forEach(function(d) {
                d.LatLng = new L.LatLng(d.lat,d.lon)
            })



            // .append("a")
            // .attr("xlink:href", function(d){return "/psmsl/" + d.id;})


            // Add groups so we can translate to location of station
            var maptrends = mapg.selectAll("g")
                    .data(collection)
                    .enter()
                    .append("g")
                    .classed("maptrend", true)
                    .append("a")
                    .attr("xlink:href", function(d){return ".?" + $.param({station: d.name});})
                    .append("circle")
                    .attr("cx", 0)
                    .attr("cy", 0)
                    .attr("r", 4)
                    .attr("id", function(d){return "circle" + d.id})
                    .attr("fill", function(d,i) {
                        fill = colorscale(d.coef["year.month"]);
                        return fill;
                    })

                    // .append("path")
                    // .attr("id", function(d){return "mappath" + d.id})
                    // .attr("stroke", function(d,i) {
                    //     stroke = d3.interpolateHsl(color[0], color[1])(((d.coef["year.month"] - 2 + 20)/40));
                    //     return stroke;
                    // })
                    .on("mouseover", function(d){
                        d3.select("#plotpath" +d.id).classed("selected", true);
                        d3.select(this).classed("selected", true);
                    })
                    .on("mouseout", function(d){
                        d3.select("#plotpath" +d.id).classed("selected", false);
                        d3.select(this).classed("selected", false);
                    });

            // No need to translate
            var plottrends = plotg.selectAll("path")
                    .data(collection)
                    .enter()
                    .append("path")
                    .classed('plottrend', true)
                    .attr("id", function(d){return "plotpath" + d.id})
                    .attr("stroke", function(d,i) {
                        stroke = colorscale(d.coef["year.month"]);
                        return stroke;
                    })
                    .on("mouseover", function(d){
                        d3.select("#circle" +d.id).classed("selected", true);
                        d3.select(this).classed("selected", true);
                    })
                    .on("mouseout", function(d){
                        d3.select("#circle" +d.id).classed("selected", false);
                        d3.select(this).classed("selected", false);
                    });


            d2translate = function(d){
                x = map.latLngToLayerPoint(d.LatLng).x;
                y = map.latLngToLayerPoint(d.LatLng).y;
                txt = "translate(" + x.toFixed(2) + "," + y.toFixed(2) + ")";
                return txt;

            }
            updatemaptrends = function() {
                d3.selectAll("g.maptrend")
                    .attr("transform", function(d){ return d2translate(d)})
                    .select("path")
                    .attr("d", function(d,i){
                        line = d3.svg.line()
                            .x(function(x,i){return d.y[i]/5  })
                            .y(function(x,i){return -d.h[i]/20 })(d.y );
                        return line;
                    })

            };

            updateplottrends = function() {
                d3.select("#plotg")
                    .selectAll("path")
                    .attr("d", function(d,i){
                        line = d3.svg.line()
                            .interpolate("basis")
                            .x(function(x,i){return xscale(d.y[i] + 1970) })
                            .y(function(x,i){
                                return yscale(d.h[i] - d.wl1900); }
                              )(d.y);
                        return line;
                    })
            };

            update = function(){
                updatemaptrends();
                updateplottrends();

            };
            map.on("viewreset", update);
            update();
        });
       })



