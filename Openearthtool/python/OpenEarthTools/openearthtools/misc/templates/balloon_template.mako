<![CDATA[
<table border="1"> <tr>
<td width=75px>EPSG code  </td><td class="dates">${epsg}</td></tr>
<td>xmin   </td><td class="dates">${xmin}</td></tr>
<td>xmax   </td><td class="dates">${xmax}</td></tr>
<td>ymin   </td><td class="dates">${ymin}</td></tr>
<td>ymax   </td><td class="dates">${ymax}</td></tr>
</table>
<hr>
<h3>Available time instances</h3>
${comment}
<br>
<table border="1"> <tr>
<td class="dates">date</td><td class="dates">coverage</td></tr>
% for d,c in datecov:
    <td class="dates">${d}</td><td class="dates">${c}</td></tr>
% endfor
</table>
<hr>
<h3>Meta information</h3>
<table border="0"> <tr>
<td>netCDF</td><td><a href="${opendapurl}">meta info</a></td></tr>
<td>download</td><td><a href="${ftpurl}">netCDF via ftp</a></td></tr>
</table>
]]>
