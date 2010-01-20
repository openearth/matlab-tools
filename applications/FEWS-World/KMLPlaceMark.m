function KMLPlaceMark(lat,lon,kmlName,varargin)


OPT.name          = '';
OPT.description   = '';
OPT.Z             = zeros(size(lat));
OPT.icon               = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
[OPT, Set, Default] = setProperty(OPT, varargin{:}); 
if nargin<3
    disp('Minimal number of arguments is 3 (lat, lon, filename)');
  return
end 
if length(lat)~=length(lon)
    disp('lats and lons must have same lengths');
    return
end
fid = fopen(kmlName,'w');
fprintf(fid,'%s\n','<Document>');
for place = 1:length(lat)
    fprintf(fid,'%s\n','<Placemark id="point">');
    fprintf(fid,'%s\n','<IconStyle><Icon><href>');
    fprintf(fid,'%s\n',['  ' OPT.icon]);
    fprintf(fid,'%s\n','</href></Icon></IconStyle>');
    fprintf(fid,'%s\n','<name>');
    fprintf(fid,'%s\n',['  ' OPT.name{place}]);
    fprintf(fid,'%s\n','</name>');
    fprintf(fid,'%s\n','<visibility>');
    fprintf(fid,'%s\n','  1');
    fprintf(fid,'%s\n','</visibility>');
    fprintf(fid,'%s\n','<description>');
    fprintf(fid,'%s\n',['  <![CDATA[' OPT.description{place} ']]>']);
    fprintf(fid,'%s\n','</description>');
    fprintf(fid,'%s\n','<Style>');
    fprintf(fid,'%s\n','</Style>');
    fprintf(fid,'%s\n',['<Point id="Marker_' num2str(place) '">']);
    fprintf(fid,'%s\n','<altitudeMode>relativeToGround</altitudeMode>');
    fprintf(fid,'%s\n','<tessellate>');
    fprintf(fid,'%s\n','1');
    fprintf(fid,'%s\n','</tessellate>');
    fprintf(fid,'%s\n','<extrude>0</extrude>');
    fprintf(fid,'%s\n','<coordinates>');
    fprintf(fid,'%s\n',['  ' num2str(lat(place)) ',' num2str(lon(place)) ',' num2str(OPT.Z(place))]);
    fprintf(fid,'%s\n','</coordinates>');
    fprintf(fid,'%s\n','</Point>');
    fprintf(fid,'%s\n','</Placemark>');
end
fprintf(fid,'%s\n','</Document>');

fclose(fid);