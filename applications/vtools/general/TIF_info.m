%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Extract bounding boxes of TIFF files referenced
%
%INPUT
%   - fpath_vrt = string path to the VRT XML file
%
%OUTPUT
%   - vrtBounds = struct array with fields:
%       Filename = string TIFF filename as referenced in VRT
%       MinX, MaxX, MinY, MaxY = bounding box in spatial coordinates

%
%OPTIONAL (pair input)
%   - image_info = output of <imfinfo> for the same file. Reading it is
%       expensive, so pass it when calling repeatedly on the same file.
%
%TODO:
%   -
%
%E.G.

function [image_info,no_data,x_vector,y_vector,fcn_data_type]=TIF_info(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'image_info',[]);

parse(parin,varargin{:});

image_info=parin.Results.image_info;

%% CALC

if isempty(image_info)
    if ~exist(fname,'file')
        error('File %s does not exist',fname);
    end
    image_info=imfinfo(fname);
elseif ~strcmp(canonical_path(image_info.Filename),canonical_path(fname))
    error('The given <image_info> belongs to %s but the requested file is %s',image_info.Filename,fname)
end

ncolumns=image_info.Width;
nrows=image_info.Height;
% info.imsize  = image_info.Offset;
% info.bands   = TncolumnsPerPixel;

%data_type = Tinfo.BitDepth/8;
data_type=image_info.BitsPerSample(1)/8;
no_data_string=image_info.GDAL_NODATA;
no_data=str2double(no_data_string);

dx=image_info.ModelPixelScaleTag(1);
dy=image_info.ModelPixelScaleTag(2);
x0=image_info.ModelTiepointTag(4);
y0=image_info.ModelTiepointTag(5);

%info.map_info.projection_name = Tinfo.GeoAsciiParamsTag;
%info.map_info.projection_info = Tinfo.GeoDoubleParamsTag;

% maxx = x0 + (ncolumns-1).*dx;
% miny = y0 - (nrows-1  ).*dy;

%info.CornerMap = [minx miny; maxx miny; maxx maxy; minx maxy; minx miny]; 

%% GET EMPTY

switch data_type
    case {1}
        fcn_data_type=@(X)uint8(X);
    case {2}
        fcn_data_type=@(X)int16(X);
    case{3}
        fcn_data_type=@(X)int32(X);
    case {4}
        fcn_data_type=@(X)single(X);
end

no_data=fcn_data_type(no_data);

%% coordinates

% I assume that the x-direction is normal and the y-direction is reversed.
% This information may be somewhere in the image information.

x_vector=x0+((0:ncolumns-1).*dx);
y_vector=y0-((0:nrows   -1).*dy);

end %function

%%

function fpath=canonical_path(fpath)

%<imfinfo> resolves the path, so a path holding <..> must be resolved
%before it can be compared
try
    fpath=char(java.io.File(fpath).getCanonicalPath());
catch
    %the comparison stays literal if java is not available
end

end %function