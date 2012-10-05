function varargout = KML2Coordinates(FileName)
% KML2POLYGONCOORDINATES transforms .kml polygons/paths into a Matlab cell
% 
%   varargout = KML2COORDINATES(FileName) 
%   returns a cell of arrays MX3. 
%   The arrays are double arrays, each composed of xyz coordinates of the points 
%   of the specific polygon (path). 
%   Cell size depends on the number of polygons/paths in the file. 
%   
%   KML2COORDINATES parses the .kml (.kmz) file, looks for tag <coordinates>, and
%   records the coordinates as an array of size MX3.
%
%   KML2COORDINATES reads Coordinates as x,y,z either displaced in column or in a row
%
%   Example:
%       % polygons of buildings
%       FileName = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
%       lat = nc_varget(FileName,'lat');
%       lon = nc_varget(FileName,'lon');
%       KMLline(lat,lon,'fileName','holland_fillable.kml','lineColor',[1 .5 0],'lineWidth', 2);
%       p = KML2Coordinates('holland_fillable.kml');
%
% See also: googleplot, line, patch

if strcmp(FileName(end-3:end),'.kmz')
    unzip('Copy_of_pathtest.kmz');
    fid = fopen([FileName(1:end-4) '.kml']);
elseif strcmp(FileName(end-3:end),'.kml')
	fid = fopen(FileName);
else
	fid = fopen([FileName '.kml']);
end

jj  = 0;
while ~feof(fid)
    newline = textscan(fid, '%s', 1);
    if strcmp(newline{:},'<coordinates>')
        fgetl(fid);
        jj = jj+1;
        coordline = fgetl(fid);
        
        % coordinates x,y,z displaced in column
        if length(regexp(coordline, ',')) == 2
            kk = 0;
            while ~strcmp(char(regexp(coordline,'</coordinates>','match')),'</coordinates>')
                kk = kk+1;
                coord{kk,:} = str2num(coordline);
                coordline = fgetl(fid);
            end
            coordCell{jj} = cell2mat(coord);
            clear coord;
            
        else % coordinates x,y,z displaced in a row
            coord = (reshape(str2num(coordline),3,[]))';
            coordCell{jj} = coord;
            clear coord;
        end
        
    end

end
fclose(fid);

varargout = {coordCell};