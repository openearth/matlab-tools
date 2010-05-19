function S = gshhs(varargin)
%GSHHS Read Global Self-consistent Hierarchical High-resolution Shoreline
%
%   S = GSHHS(FILENAME) reads GSHHS version 1.3 and earlier vector data
%   for the entire world from FILENAME.  GSHHS files have names of the form
%   'gshhs_X.b', where X is one of the letters c, l, i, h  and f,
%   corresponding to increasing resolution (and file size). The result
%   returned in S is a polygon geographic data structure array. 
%
%   S = GSHHS(FILENAME, LATLIM, LONLIM) subsets the data from FILENAME
%   using the quadrangle defined by the latitude and longitude limits in
%   LATLIM and LONLIM. Any feature whose bounding box intersects the
%   quadrangle is returned, without trimming.  LATLIM and LONLIM are
%   2-element vectors with latitude and longitude in degrees in ascending
%   order. Longitude limits range from [-180 195]. If LATLIM is empty the
%   latitude limits are [-90 90]. If LONLIM is empty, the longitude limits
%   are [-180 195]. 
%
%   INDEXFILENAME = GSHHS(FILENAME,'createindex') creates an index file for
%   faster data access when requesting a subset of a larger dataset. The
%   index file has the same name as the GSHHS data file, but with the
%   extension 'i', instead of 'b' and is written in the same directory as
%   FILENAME. The name of the index file is returned, but no coastline data
%   are read. A call using this option should be followed by an additional
%   call to GSHHS to import actual data.
%
%   Output structure
%   ----------------
%   The output structure S contains the following fields.
%   All latitude and longitude values are in degrees.
%
%     Field name            Field contents            
%     ----------            -----------------         
%     'Geometry'            'Polygon'       
%
%     'BoundingBox'         [min Lon min Lat;         
%                            max Lon max Lat]             
%
%     'Lon'                 Coordinate vector         
%                                                     
%     'Lat'                 Coordinate vector       
%
%     'South'               Southern latitude boundary 
%
%     'North'               Northern latitude boundary
%
%     'West'                Western longitude boundary 
%
%     'East'                Eastern longitude boundary 
%
%     'Area'                Area of polygon in square kilometers
%
%     'Level'               Scalar value ranging from 1 to 4, 
%                           indicates level in topological hierarchy
%
%     'LevelString'         'land' or 'lake', or 'island_in_lake', or 
%                           'pond_in_island_in_lake' or 'other'
%
%     'NumPoints'           Number of points in the polygon
%
%     'FormatVersion'       Format version of data: empty if unspecified
%
%     'Source'              Source of data: 'WDBII' or 'WVS'
%
%     'CrossGreenwich'      Scalar flag: true if the polygon
%                           crosses the prime meridian, false otherwise
%
%     'GSHHS_ID'            Unique polygon scalar id number, starting at 0
%
%   For details on locating GSHHS data for download over the Internet, see
%   the following documentation at the MathWorks web site: 
%
%   <a href="matlab: 
%   web('http://www.mathworks.com/support/tech-notes/2100/2101.html#gshhs') 
%   ">http://www.mathworks.com/support/tech-notes/2100/2101.html</a>
%
%
%   Example 1
%   ---------
%   % Read the entire coarse data set
%   % and display as a coastline.
%   filename = gunzip('gshhs_c.b.gz', tempdir);
%   world = gshhs(filename{1});
%   delete(filename{1})
%   figure
%   worldmap world
%   geoshow([world.Lat], [world.Lon])
%
%   Example 2
%   ---------
%   % Read and display Africa as a green polygon.
%   filename = gunzip('gshhs_c.b.gz', tempdir);
%   indexname = gshhs(filename{1}, 'createindex');
%   figure
%   worldmap Africa
%   projection = gcm;
%   latlim = projection.maplatlimit;
%   lonlim = projection.maplonlimit;
%   africa = gshhs(filename{1}, latlim, lonlim);
%   delete(filename{1})
%   delete(indexname)
%   geoshow(africa, 'FaceColor', 'green')
%   setm(gca, 'FFaceColor', 'cyan')
%
%   See also GEOSHOW, SHAPEREAD, WORLDMAP.

% Copyright 1996-2006 The MathWorks, Inc. 
% $Revision: 2568 $  $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $

% Check number of inputs
checknargin(1,3,nargin,mfilename);

% Parse the inputs
[latlim, lonlim, filename, create_index, subset] = parseInputs(varargin{:});

% Open the data file in binary mode, with big endian byte ordering.
FileID = fopen(filename,'rb','ieee-be');
if FileID==-1
   eid = sprintf('%s:%s:invalidFileModes', getcomp, mfilename);
   error(eid, 'Unable to open file ''%s''.',filename)
end

% Create the index file, if requested
if create_index
   ifilename = createIndexFile(FileID, filename);
   fclose(FileID);
   S = strrep(ifilename,'\','/');
 
else
   % Get the index filename if it exists
   ifilename = getIndexFilename(filename);

   % Read the data file
   if ~isempty(ifilename) && subset
      % Read only data within limits using the index file
      S = gshhsReadUsingIndex(FileID,latlim,lonlim,ifilename);
   else
      % Read all of the file keeping only parts within coordinate limits
      S = gshhsRead(FileID,latlim,lonlim,subset);
   end

   %  Close file
   fclose(FileID);
   
end

%--------------------------------------------------------------------------
function [latlim, lonlim, filename, create_index, subset] = parseInputs(varargin)
% PARSEINPUTS Parse and return input arguments

dataLatLim = [-90 90];
dataLonLim = [-180 195];

create_index = 0;
% Input checks.
switch nargin
   case 1
      filename = varargin{1};
      subset = 0;
      latlim = dataLatLim;
      lonlim = dataLonLim;
   case 2
      filename = varargin{1};
      if ischar(varargin{2}) && strncmpi(varargin{2},'createindex',length(varargin{2}))
         create_index = 1;
      else
         eid = sprintf('%s:%s:nonCharInput', getcomp, mfilename);
         error(eid,'%s%s%s', 'Function ', upper(mfilename), ...
            ' expected its second argument to be the string ''createindex''. ');
      end
      subset = 0;
      latlim = dataLatLim;
      lonlim = dataLonLim;
   case 3
      filename = varargin{1};
      latlim = varargin{2};
      lonlim = varargin{3};
      if isempty(latlim)
         latlim = dataLatLim;
      end
      if isempty(lonlim)
         lonlim = dataLatLim;
      end
      subset = 1;
end

if ~ischar(filename)
   eid = sprintf('%s:%s:invalidType', getcomp, mfilename);
   msg = sprintf('FILENAME must be a char input.');
   error(eid, '%s', msg);
end

if ~exist(filename,'file')
   eid = sprintf('%s:%s:fileNotFound', getcomp, mfilename);
   msg = sprintf('GSHHS data file "%s" does not exist.',filename);
   error(eid, '%s', msg);
end

checkinput(latlim,{'double'},{'real','vector','finite'},mfilename, ...
   'LATLIM',2);
checkinput(lonlim,{'double'},{'real','vector','finite'},mfilename, ...
   'LONLIM',3);

if numel(latlim) ~= 2
   eid = sprintf('%s:%s:invalidLatLim', getcomp, mfilename);
   error(eid,'latlim must be a two element vector in units of degrees');
end

if numel(lonlim) ~= 2
   eid = sprintf('%s:%s:invalidLonLim', getcomp, mfilename);
   error(eid,'lonlim must be a two element vector in units of degrees');
end

if latlim(1)>latlim(2)
   eid = sprintf('%s:%s:invalidLatOrder', getcomp, mfilename);
   error(eid,'1st element of latlim must be greater than 2nd')
end

if lonlim(1)>=lonlim(2)
   eid = sprintf('%s:%s:invalidLonOrder', getcomp, mfilename);
   error(eid,'1st element of lonlim must be greater than 2nd')
end

if latlim(1)<-90 || latlim(2)>90
   eid = sprintf('%s:%s:invalidLatLimits', getcomp, mfilename);
   error(eid,'latlim must be between -90 and 90')
end

if any(lonlim<dataLonLim(1)) || any(lonlim>dataLonLim(2))
   eid = sprintf('%s:%s:invalidLonLimits', getcomp, mfilename);
   error(eid,'%s%g%s%g','lonlim must be between ',dataLonLim(1), ...
      ' and ',dataLonLim(2))
end

%--------------------------------------------------------------------------
function ifilename = getIndexFilename(filename)
% GETINDEXFILENAME Return the name of the index file

ifilename = filename;
ifilename(end) = 'i';
if ~exist(ifilename,'file')
   ifilename(end) = 'I';
   if ~exist(ifilename,'file')
      ifilename = [];
   end
end

%--------------------------------------------------------------------------
function ifilename = createIndexFile(FileID,filename)
% CREATEINDEXFILE Create the GSHHS index file

%  Verify that we can open index file
ifilename = filename;
ifilename(end) = 'i';
%fprintf(['Creating index file ''' ifilename '''\n'])
iFileID = fopen(ifilename,'w','ieee-be');
if iFileID == -1
   fclose(FileID);
   eid = sprintf('%s:%s:invalidIndexFileModes', getcomp, mfilename);
   error(eid, 'Unable to open index file ''%s'' for writing.',ifilename)
end

% Get the end and beginning file positions
[EOF, BOF] = getEofBofFilePositions(FileID);

% For each polygon, read header block, and if within limits read the
% coordinates
degreesPerMicroDegree = 1.0E-06;
dataBlockLengthInBytes = 8; % Lat, Lon in INT32
FilePosition = BOF;
while FilePosition ~= EOF

   % Read header info.
   S = readAttributes(FileID);

   % Write index file
   fwrite(iFileID, ...
      [S.NumPoints [S.West S.East S.South S.North]./degreesPerMicroDegree],'int32');

   % Move to the end of this data block.
   Offset = S.NumPoints*dataBlockLengthInBytes;
   status = fseek(FileID,Offset,'cof');
   if status == -1
      error(ferror(FileID));
   end
   FilePosition = ftell(FileID);

end  % end while loop

fclose(iFileID);

%--------------------------------------------------------------------------
function [EOF, BOF] = getEofBofFilePositions(FileID)
% GETEOFFILEPOSITION Get the end-of-file and beginning-of-file positions

% Get the end of file position.
status = fseek(FileID,0,'eof');
if status == -1
   error(ferror(FileID));
end
EOF = ftell(FileID);

% Go back to the beginning of the file.
status = fseek(FileID,0,'bof');
if status == -1
   error(ferror(FileID));
end
BOF = ftell(FileID);

%--------------------------------------------------------------------------
function [S, numHeaderBytes] = readAttributes(FileID)
%READATTRIBUTES Read the GSHHS attributes from the header records

areaDecodeFactor   = .1;        % Multiply by this to get back to km^2
degreeDecodeFactor = 1.0E-06;   % Multiply by this to get back to degrees

numHeaderBytes = 0;
% Read INT32 header attributes
[H32,count] = fread(FileID,8,'int32');
if count ~= 8
   errorMsg = sprintf('%s\n%s%d%s', ...
      'Expecting to read 8 int32 header values.', ...
      'Instead read ',count,' int32 values.');
   attribError(FileID, 'invalidInt32HeaderCount', errorMsg)
end

numHeaderBytes = count*4 + numHeaderBytes;

% Check the version number
[version, count] = fread(FileID, 1, 'int32');
if count ~= 1
   errorMsg = sprintf('%s\n%s%d%s', ...
      'Expecting to read 1 int16 header values.', ...
      'Instead read ',count,' int16 values.');
   attribError(FileID, 'invalidInt16HeaderCount', errorMsg)
end


if version ~= 3
   formatVersion = [];
   offSet = -4; % 4-bytes per INT32
   fseek(FileID,offSet,'cof');
else
   formatVersion = double(version);
   numHeaderBytes = count*4 + numHeaderBytes;
end

% Read INT16 header attributes
[H16,count] = fread(FileID,2,'int16');
if count ~= 2
   errorMsg = sprintf('%s\n%s%d%s', ...
      'Expecting to read 2 int16 header values.', ...
      'Instead read ',count,' int16 values.');
   attribError(FileID, 'invalidInt16HeaderCount', errorMsg)
end

numHeaderBytes = count*2 + numHeaderBytes;


% Convert lat,lon limits to degrees
H32(4:7) = H32(4:7) .* degreeDecodeFactor;

% H32 Header
id     = H32(1);
n      = H32(2); % Number of points in this polygon
level  = H32(3); % 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
west   = H32(4);
east   = H32(5);
south  = H32(6);
north  = H32(7);
area   = H32(8) * areaDecodeFactor;
switch level
   case 1
      levelString = 'land';
   case 2
      levelString = 'lake';
   case 3
      levelString = 'island_in_lake';
   case 4
      levelString = 'pond_in_island_in_lake';
   otherwise
      levelString = 'other';
end

% H16 Header
gcross = H16(1);

if H16(2) == 0   % 0 = CIA WDBII, 1 = WVS
   source = 'WDBII';
else
   source = 'WVS';
end

% Create the geostruct
S = createGeoStruct(id, n, south, north, west, east, level, levelString, ...
   area, source, gcross, formatVersion);

% Verify INT32 attributes
if n <= 0 || n*2 > intmax('int32') % lat,lon pairs
   errorMsg = sprintf('%s%g%s', ...
      'Invalid number of polygon points, "',n,'".');
   attribError(FileID, 'invalidNumPoints', errorMsg)
end

if id < 0
   errorMsg = sprintf('%s%g%s', ...
      'Invalid GSHHS ID, "',id,'".');
   attribError(FileID, 'invalidId', errorMsg)
end

if south < -91 || south > 91  || ...
      north < -91 || north > 91  || ...
      east < -181 || east > 361  || ...
      west < -181 || west > 361
   errorMsg = sprintf('%s', ...
      'Invalid coordinate limits.');
   attribError(FileID, 'invalidCoordinateLimits', errorMsg)
end

% Verify INT16 attributes
if gcross > 1 || gcross < 0
   errorMsg = sprintf('%s%g%s', ...
      'Invalid Greenwich crossing flag, "',gcross,'".');
   attribError(FileID, 'invalidGreenwichCrossFlag', errorMsg)
end

%--------------------------------------------------------------------------
function attribError(FileID, errorId, errorMsgPart2)
% ATTRIBERROR Output common error message for attribute reading

fname = fopen(FileID);
fclose(FileID);
id  = sprintf('%s:%s:%s','map', lower(mfilename), errorId);
msg = sprintf('%s%s%s\n%s', ...
   'Invalid attribute header in file "',fname,'".', ...
   errorMsgPart2);
error(id, '%s', msg);

%--------------------------------------------------------------------------
function S = createGeoStruct( ...
   id, n, south, north, west, east, level, levelString, area, source, ...
   gcross, version)
% CREATEGOSTRUCT Create a geostruct to hold GSHHS data

% Write the data to the output geographic data structure.
S = struct( 'Geometry',    'Polygon', ...
   'BoundingBox', [], ...
   'Lat',         [], ...
   'Lon',         [], ...
   'South',       south, ...
   'North',       north, ...
   'West',        west, ...
   'East',        east, ...
   'Area',        area, ...
   'Level',       level, ...
   'LevelString', levelString, ...
   'NumPoints',   n, ...
   'FormatVersion', version, ...
   'Source',      source, ...
   'CrossGreenwich', gcross, ...
   'GSHHS_ID',    id);

%--------------------------------------------------------------------------
function S = gshhsRead(FileID,latlim,lonlim,subset)
% GSHHSREAD reads all records in gshhs file

% Get the end and beginning file positions
[EOF, BOF] = getEofBofFilePositions(FileID);
if EOF == 0
   fname = fopen(FileID);
   fclose(FileID);
   error('map:gshhs:noDataInFile','%s%s%s','Invalid GSHHS file "',fname,'"');
end

% For each polygon, read header block,
% and if within limits read the coordinates
k = 0;
dataBlockLengthInBytes = 8;
FilePosition = BOF;
while FilePosition ~= EOF

   % Read header info.
   A = readAttributes(FileID);

   % Determine if any of the data in the current block falls within the
   % input limits. If so, read the data.  If not, move to the end of the
   % block.
   if subset
      DataWithinLimits = checkDataLimits( ...
         A.West, A.East, A.South, A.North, latlim, lonlim);
   else
      DataWithinLimits = 1;
   end

   if DataWithinLimits

      % Increment the counter and set the output structure
      k = k + 1;
      S(k) = A;

      %Read the coordinate data.
      [S(k).Lat, S(k).Lon, S(k).BoundingBox] = readData(FileID, A);

   else

      % Move to the end of this data block.
      Offset = A.NumPoints*dataBlockLengthInBytes;
      status = fseek(FileID,Offset,'cof');
      if status == -1
         error(ferror(FileID));
      end
   end
   FilePosition = ftell(FileID);

end  % end while loop

% Check in case no data is found within limits
if k == 0
   S = [];
end

%--------------------------------------------------------------------------
function S = gshhsReadUsingIndex(FileID,latlim,lonlim,ifilename)
% GSHHSREADUSINGINDEX Read the GSHHS file using an index file for speed

% Open the index file again and get the file size
iFileID = fopen(ifilename,'rb','ieee-be');
if iFileID == -1
   fclose(FileID);
   eid = sprintf('%s:%s:indexFopenError', getcomp, mfilename);
   error(eid, 'Unable to open index file ''%s'' for reading.',ifilename)
end
fseek(iFileID,0,'eof');
ifilelength = ftell(iFileID);
fclose(iFileID);

% count number of records in index file
[extractindx,npolypts] = inlimitpolys(ifilename, ifilelength, latlim, lonlim);

% Get the number of header bytes
numberOfHeaderBytes = getNumberOfHeaderBytes(FileID);

% For each polygon within limits, read header block and coordinates
k = 1;
if ~isempty(extractindx)
   for i=1:length(extractindx)
      % Read header info. Skip data from preceding polyons
      bytesbefore = (extractindx(i)-1)*numberOfHeaderBytes + ...
         sum( npolypts(1:extractindx(i)-1,1) )*8;
      if ~isempty(bytesbefore)
         status = fseek(FileID,bytesbefore,'bof');
         if status == -1
            error(ferror(FileID));
         end
      end

      % Read the attribute header.
      S(k) = readAttributes(FileID);

      %Read the coordinate data.
      [S(k).Lat, S(k).Lon, S(k).BoundingBox] = readData(FileID, S(k));
      
      % Increment the counter 
      k = k + 1;

   end  % end while loop
else
   S = [];
end

%--------------------------------------------------------------------------
function numberOfHeaderBytes = getNumberOfHeaderBytes(FileID)
[S, numberOfHeaderBytes] = readAttributes(FileID);
status = fseek(FileID,-numberOfHeaderBytes,'cof');
if status == -1
   error(ferror(FileID));
end

%--------------------------------------------------------------------------
function [lat,lon,bbox] = readData(FileID,A)
% READDATA Read the latitude, longitude data and compute a bounding box

[Data,count] = fread(FileID,[2,A.NumPoints],'int32');
if count ~= 2*A.NumPoints
   eid = 'map:gshhs:dataReadError';
   error(eid,'%s%d%s\n%s%d%s\n', ...
      'Expecting to read ',2*n,' latitude, longitude values.', ...
      'Instead read only ',count,' latitude, longitude values.');
end

% Convert to degrees
degreesPerMicroDegree = 1.0E-06;
lat = degreesPerMicroDegree*Data(2,:);
lon = degreesPerMicroDegree*Data(1,:);

% Fix longitude wrapping
lon(lon>A.East) = lon(lon>A.East) - 360;
if A.West > 180
   lon = lon - 360;
end

% Convert to clockwise ordering
% [lon, lat] = poly2cw(lon,lat);
if clockpoly(lon,lat)==-1
    lon=fliplr(lon);
    lat=fliplr(lat);
end
% Fix Antarctica
if A.South == -90
   if lon(1) == lon(end)
      lon(end) = [];
      lat(end) = [];
   end
   indexEast = find(lon < 180);
   indexWest = find(lon > 180);
   index = [fliplr(indexWest) fliplr(indexEast)];
   lon = lon(index);
   lat = lat(index);
   lon(lon > 180) = lon(lon > 180) - 360;
end

% Terminate with NaN
lon(end+1) = NaN;
lat(end+1) = NaN;

% Compute the bounding box
bbox = [ min(lon) min(lat); max(lon) max(lat)];

%--------------------------------------------------------------------------
function DataInLimits = checkDataLimits(west,east,south,north,latlim,lonlim)
% CHECKDATALIMITS returns 0 if the data in the current data block falls
% entirely outside the input limits (latlim & lonlim), and 1 if any part of
% the data falls inside the input limits.

% west = npi2pi(west);
west=mod(west+180,360)-180;
% east = npi2pi(east);
east=mod(east+180,360)-180;
east(east < west) = east(east < west) + 360;

DataInLimits = ...
  ((west >= lonlim(1) & east <= lonlim(2))   | ...  % data region is entirely within lonlim
   (west <= lonlim(1) & east >= lonlim(2))   | ...  % lonlim is entirely within data region
   (west  < lonlim(1) & east  > lonlim(1))   | ...  % lonlim(1) falls within data region
   (west  < lonlim(2) & east  > lonlim(2)))    ...  % lonlim(2) falls within data region
   & ...
  ((south >= latlim(1) & north <= latlim(2)) | ...  % data region is entirely within latlim
   (south <= latlim(1) & north >= latlim(2)) | ...  % latlim is entirely within data region
   (south  < latlim(1) & north  > latlim(1)) | ...  % latlim(1) falls within data region
   (south  < latlim(2) & north  > latlim(2)));      % latlim(2) falls within data region

%--------------------------------------------------------------------------
function [extractindx,npolypts] = inlimitpolys(ifilename,ifilelength,latlim,lonlim)
% INLIMITPOLYS check number of polygons in the file

%total bytes in index file/( bits per number * number of numbers per record / bits/byte)
npoly = ifilelength/(32*5/8);

extractindx = [];
blocksize = 2000;
startblock = 0;
nrows  = npoly;
ncols = 5; % npts, latlim,lonlim

% read number of points in each polygon from the index file
readcols = [1 1];
readrows = [1 npoly];
npolypts = readmtx(ifilename,nrows,ncols,'int32',readrows,readcols,'ieee-be');

% identify polygons in latlim. Do this in blocks to reduce memory
% requirements
readcols = [2 5];
while 1

   readrows = [startblock*blocksize+1 min((startblock+1)*blocksize,npoly)];
   bbox = readmtx(ifilename,nrows,ncols,'int32',readrows,readcols,'ieee-be');
   bbox = bbox * 1.0E-06; % degrees (west east south north)

   % identify polygons that fall within the limits
   extractindx = ...
      [extractindx; ...
      (startblock*blocksize + ...
      find(checkDataLimits( bbox(:,1),bbox(:,2),bbox(:,3),bbox(:,4),...
      latlim,lonlim)) ) ...
      ]; 

   if max(readrows) == npoly
      break
   end
   startblock = startblock+1;
end
