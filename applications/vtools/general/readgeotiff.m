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
%Read geotiff files. This function stems from <GEOTIFF_READ>. 
%Unfortunaltely, in that function reading of the <z> variable
%is not always correct. Hence, I read the <z> variable using
%imread. 
%
%INPUT
%   -
%
%OUTPUT
%   -
%
%TODO:
%   -
%
%E.G.
%
% [I,Tinfo]=readgeotiff('p:\archivedprojects_tmp\11210364-003-maas-mor\B_Background\03_processed_data\20240216_bodemdata_2020_2023\01_soundings2belevelmaps\2019_gridcell\691\691.tif');
% 
% figure
% imagesc(I.x, I.y, I.z);  % x and y are vectors
% set(gca,'YDir','normal')
% set(gca().Children, 'AlphaData', I.mask);
% colorbar

function [I,Tinfo]=readgeotiff(varargin)

%% START COPY <GEOTIFF_READ>

name = varargin{1};

Tinfo        = imfinfo(name);
info.samples = Tinfo.Width;
info.lines   = Tinfo.Height;
info.imsize  = Tinfo.Offset;
info.bands   = Tinfo.SamplesPerPixel;

sub = [1, info.samples, 1, info.lines];
%data_type = Tinfo.BitDepth/8;
data_type = Tinfo.BitsPerSample(1)/8;
switch data_type
    case {1}
        format = 'uint8';
    case {2}
        format = 'int16';
    case{3}
        format = 'int32';
    case {4}
        format = 'single';
end

info.map_info.dx = Tinfo.ModelPixelScaleTag(1);
info.map_info.dy = Tinfo.ModelPixelScaleTag(2);
info.map_info.mapx = Tinfo.ModelTiepointTag(4);
info.map_info.mapy = Tinfo.ModelTiepointTag(5);
%info.map_info.projection_name = Tinfo.GeoAsciiParamsTag;
%info.map_info.projection_info = Tinfo.GeoDoubleParamsTag;

minx = info.map_info.mapx;
maxy = info.map_info.mapy;
maxx = minx + (info.samples-1).*info.map_info.dx;
miny = maxy - (info.lines-1  ).*info.map_info.dy;

%info.CornerMap = [minx miny; maxx miny; maxx maxy; minx maxy; minx miny]; 

xm = info.map_info.mapx;
ym = info.map_info.mapy;
x_ = xm + ((0:info.samples-1).*info.map_info.dx);
y_ = ym - ((0:info.lines  -1).*info.map_info.dy);
 
tmp1=[1 2];
tmp2=[4 3];
if nargin == 3
    
    if strcmp(varargin{2},'pixel_subset')
        sub = varargin{3};
        
    elseif strcmp(varargin{2},'map_subset')
        sub  = varargin{3};
        subx = (sub(tmp1)-info.map_info.mapx  )./info.map_info.dx+1;
        suby = (info.map_info.mapy - sub(tmp2))./info.map_info.dy+1;
        subx = round(subx);
        suby = round(suby);
        
        subx(subx < 1) = 1;
        suby(suby < 1) = 1;
        subx(subx > info.samples) = info.samples;
        suby(suby > info.lines  ) = info.lines;
        sub = [subx,suby];
    end
    info.sub.samples = sub(2)-sub(1)+1;
    info.sub.lines   = sub(4)-sub(3)+1;
    info.sub.mapx = [ x_(sub(1)) x_(sub(2)) ];
    info.sub.mapy = [ y_(sub(3)) y_(sub(4)) ];
    info.sub.pixx = [sub(1) sub(2)];
    info.sub.pixy = [sub(3) sub(4)];
end
       
I.x = x_(sub(1):sub(2));
I.y = y_(sub(3):sub(4));

% END COPY <GEOTIFF_READ>

%% GET EMPTY

no_data_string=Tinfo.GDAL_NODATA;
no_data=str2double(no_data_string);
switch data_type
    case {1}
        no_data=uint8(no_data);
    case {2}
        no_data=int16(no_data);
    case{3}
        no_data=int32(no_data);
    case {4}
        no_data=single(no_data);
end

%% READ

I.z=imread(name);

%% MASK

bol_empty=I.z==no_data;
I.z(bol_empty)=NaN;
I.mask=double(~bol_empty);

end %function