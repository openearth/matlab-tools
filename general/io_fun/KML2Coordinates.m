function varargout = KML2Coordinates(kmlName)
% KML2POLYGONCOORDINATES reads .kml Polygon or Path files and convert them 
% into Matlab cell.
% 
% DESCRIPTION
% 
%
%
%
%

if strcmp(kmlName(end-3:end),'.kmz')
    unzip('Copy_of_pathtest.kmz');
    fid = fopen([kmlName(1:end-4) '.kml']);
elseif strcmp(kmlName(end-3:end),'.kml')
	fid = fopen(kmlName);
else
	fid = fopen([kmlName '.kml']);
end

jj  = 0;
while ~feof(fid)
    newline = textscan(fid, '%s', 1);
    if strcmp(newline{:},'<coordinates>')
        fgetl(fid);
        jj = jj+1;
        coordline = fgetl(fid);
        coord = (reshape(str2num(coordline),3,[]))';
        coordCell{jj} = coord;
    end

end
fclose(fid);

varargout = {coordCell};