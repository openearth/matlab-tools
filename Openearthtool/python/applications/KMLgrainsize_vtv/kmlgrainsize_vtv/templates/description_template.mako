<![CDATA[
<table border="0">
<tr><td>Transect id</td><td>${data['id'][idx]}</td></tr>
<tr><td>Area (kustvak)</td></tr>
<tr><td>Name</td><td>${areaname}</td></tr>
<tr><td>Code</td><td>${"%i"%data['areacode'][idx]}</td></tr>
<tr><td>Latitude</td><td>${"%.2f"%data['lat'][idx]} &deg;N</td></tr>
<tr><td>Longitude</td><td>${"%.2f"%data['lon'][idx]} &deg;E</td></tr>
<tr><td>Mean D<sub>50</sub></td><td>${"%i"%(data['meanD50'][idx]*1e6)} &mu;m</td></tr>
<tr><td>Sigma D<sub>50</sub></td><td>${"%i"%(data['sigmaD50'][idx]*1e6)} &mu;m</td></tr>
<tr><td>Calculation D<sub>50</sub></td><td>${"%i"%(data['calcD50'][idx]*1e6)} &mu;m</td></tr>
</table>
<h3>Meta information</h3>
<table border="0" padding="0" width="200">
<tr><td>THREDDS server</td><td><a href="${url}.html">meta-info</a></td></tr>
<tr><td>Download</td><td><a href="${ftp}">netCDF via ftp</a></td></tr>
</table>
<h3>Provided by:</h3>
<a href="http://www.openearth.nl"><img src="http://kml.deltares.nl/kml/logos/OpenEarth-logo-blurred-white-background.png"  width="150"  align="left"/></a>
]]>