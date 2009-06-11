function [x2,y2,OPT]=convertCoordinatesNew(x1,y1,STD,varargin)
%CONVERTCOORDINATES   transformation between coordinate systems
%
%    [x2,y2]=convertCoordinatesNew(x1,y1,STD,'keyword','value')
%
% where x1,y1 are the values of the coordinates to be transformed.
%       x2,y2 are the values of the coordinates after transformation.
%
% Example: 4 different notations of 1 single case
%
%    [x,y]=convertCoordinatesNew(5,52,STD,'CS1.name','WGS 84','CS1.type','geo','CS2.name','WGS 84 / UTM zone 31N','CS2.type','xy')
%    [x,y]=convertCoordinatesNew(5,52,STD,'CS1.code',4326,'CS2.name','WGS 84 / UTM zone 31N')
%    [x,y]=ConvertCoordinatesNew(5,52,    4326,'geo','WGS 84 / UTM zone 31N','xy')
%    [x,y]=ConvertCoordinatesNew(5,52,    4326,'geo',                  32631,'xy')
%
% Note: (x1,y1) can be vectors or matrices (vectorized).
% To check the output, use 'var2evalstr(OPT)'

%% get and set keyword value parameters

OPT.CS1.name                   = []; % coordinate system name
OPT.CS1.code                   = []; % coordinate system reference code 
OPT.CS1.type                   = []; % projection type
                                     % projection types supported:
                                     % projected, geographic 2D
                                     %
                                     % projection not (yet) supported:
                                     % engineering, geographic 3D, vertical, geocentric,  compound
                                     %
                                     % allowed synonyms for 'projected'
                                     % 'xy','proj','cartesian','cart'
                                     % allowed sysnonyms for 'geographic 2D'
                                     % 'geo','geographic2d','latlon','lat lon','geographic'
                                     %
OPT.CS1.geoRefSys.name         = []; % associated geographic reference system name
OPT.CS1.geoRefSys.code         = []; % associated geographic reference system code
OPT.CS1.coordSys.name          = []; %
OPT.CS1.coordSys.code          = []; %
                                     %
OPT.CS1.ellips.name            = []; % ellipsoide name
OPT.CS1.ellips.code            = []; % ellipsoide code
OPT.CS1.ellips.inv_flattening  = []; % inverse flattening
OPT.CS1.ellips.semi_major_axis = []; % semi major axis
OPT.CS1.ellips.semi_minor_axis = []; % semi minor axis
                                     %
OPT.CS1.UoM.name               = []; % unit of measure name of coordinates
OPT.CS1.UoM.code               = []; % unit of measure code of coordinates
                                     %
OPT.CS1.conv.name              = []; % projection to datum conversion name
OPT.CS1.conv.code              = []; % projection to datum conversion code
OPT.CS1.conv.param.val         = []; % conversion paramter values
OPT.CS1.conv.param.code        = []; % conversion paramter codes
OPT.CS1.conv.param.name        = []; % conversion paramter names

OPT.CS2.name                   = []; 
OPT.CS2.code                   = []; 
OPT.CS2.type                   = []; 
OPT.CS2.geoRefSys.name         = []; 
OPT.CS2.geoRefSys.code         = []; 
OPT.CS2.coordSys.name          = []; 
OPT.CS2.coordSys.code          = []; 
OPT.CS2.ellips.name            = []; 
OPT.CS2.ellips.code            = []; 
OPT.CS2.ellips.inv_flattening  = []; 
OPT.CS2.ellips.semi_major_axis = []; 
OPT.CS2.ellips.semi_minor_axis = []; 
OPT.CS2.UoM.name               = []; 
OPT.CS2.UoM.code               = []; 
OPT.CS2.conv.name              = []; 
OPT.CS2.conv.code              = []; 
OPT.CS2.conv.param.val         = []; 
OPT.CS2.conv.param.code        = []; 
OPT.CS2.conv.param.name        = []; 


[OPT, Set, Default]     = setPropertyInDeeperStruct(OPT, varargin{:});
%% error check the input, and find the indices of coordinate systems in data structure 
% replace synonyms with default names. e.g. replace 'geo' with 'geographic 2D'
% reference system
OPT.CS1 = ConvertCoordinatesCheckInput(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesCheckInput(OPT.CS2,STD);
%% find coordinate reference system
OPT.CS1 = ConvertCoordinatesFindCoordRefSys(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindCoordRefSys(OPT.CS2,STD);
%% find coordinate system
OPT.CS1 = ConvertCoordinatesFindCoordSys(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindCoordSys(OPT.CS2,STD);
%% find coordinate system unit of measure
OPT.CS1 = ConvertCoordinatesFindUoM(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindUoM(OPT.CS2,STD);
%% find geographic reference system
OPT.CS1 = ConvertCoordinatesFindGeoRefSys(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindGeoRefSys(OPT.CS2,STD);
%% find datum
OPT.CS1 = ConvertCoordinatesFindDatum(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindDatum(OPT.CS2,STD);
%% find ellips
OPT.CS1 = ConvertCoordinatesFindEllips(OPT.CS1,STD);
OPT.CS2 = ConvertCoordinatesFindEllips(OPT.CS2,STD);
%% find conversion parameters
switch OPT.CS1.type
    case 'projected' % Coordinate conversion to radians
        OPT.CS1 = ConvertCoordinatesFindConversionParams(OPT.CS1,STD);
    case 'geographic 2D' % do nothing
    otherwise, error(['CRS type ''' OPT.CS1.type ''' not supported (yet)',sprintf('\n\n'),var2evalstr(OPT)])
end
switch OPT.CS2.type
    case 'projected' % Coordinate conversion to radians
        OPT.CS2 = ConvertCoordinatesFindConversionParams(OPT.CS2,STD);
    case 'geographic 2D' % do nothing
    otherwise, error(['CRS type ''' OPT.CS2.type ''' not supported (yet)',sprintf('\n\n'),var2evalstr(OPT)])
end
%% Get units of measure of in- and output
% extract coordinate system UoM name from the used coordinate system, 
% unless there is a userdefined unit of mease code or name

%% Transform input coordinates to geographic 2D radians
switch OPT.CS1.type
    case 'projected' % convert projection to geographic radians
        x1 = convertUnits(x1,OPT.CS1.UoM.name,'metre',STD);
        y1 = convertUnits(y1,OPT.CS1.UoM.name,'metre',STD);
        [x1,y1] = ConvertCoordinatesProjectionConvert(x1,y1,OPT.CS1,'xy2geo',STD);
    case 'geographic 2D' % do nothing
        x1 = convertUnits(x1,OPT.CS1.UoM.name,'radian',STD);
        y1 = convertUnits(y1,OPT.CS1.UoM.name,'radian',STD);
end

%% Datum transformation
% check if geogcrs_code1 and geogcrs_code2 are different
%
% check if there is a direct transormation between geogcrs_code1 and
% geogcrs_code2; 
% 
% * if multiple options found, use the newest unless user has defined something else
% * if no direct transformation exists, convert via WGS 84
OPT = ConvertCoordinatesFindDatumTransOpt(OPT,STD);
if strcmp('no datum transformation needed',OPT.datum_trans1)
 x2 = x1;
 y2 = y1;
else
    [x2,y2] = ConvertCoordinatesDatumTransform(x1,y1,OPT.datum_trans1);
    if isfield(OPT,'datum_trans2')
    [x2,y2] = ConvertCoordinatesDatumTransform(x2,y2,OPT.datum_trans2);
    end
end
   

%% Transform geographic 2D radians to output coordinates 
switch OPT.CS2.type
    case 'projected' % convert projection to geographic radians
        [x2,y2] = ConvertCoordinatesProjectionConvert(x1,y1,OPT.CS2,'geo2xy',STD);
        x2 = convertUnits(x2,OPT.CS2.UoM.name,'metre',STD);
        y2 = convertUnits(y2,OPT.CS2.UoM.name,'metre',STD);
    case 'geographic 2D' 
        x2 = convertUnits(x2,'radian',OPT.CS2.UoM.name,STD);
        y2 = convertUnits(y2,'radian',OPT.CS2.UoM.name,STD);
end
%% EOF
end