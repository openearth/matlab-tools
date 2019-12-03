curl -X POST -H "Content-Type: application/xml" -d @request_slope.xml http://localhost:5000/wps
timeout 5
curl -X POST -H "Content-Type: application/xml" -d @request_water.xml http://localhost:5000/wps
timeout 5
curl -X POST -H "Content-Type: application/xml" -d @request_landuse.xml http://localhost:5000/wps
timeout 5
curl -X POST -H "Content-Type: application/xml" -d @request_soil.xml http://localhost:5000/wps
