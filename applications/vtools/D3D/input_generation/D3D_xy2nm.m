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
%From a set of xy-coordinates and a grid-file (Delft3D 4), find the
%nm-coordinates of those points. 
%
%INPUT
%   -fpath_grd = full path to the Delft3D 4 grid [char]
%   -points_xy = xy-coordinates of the points [double(np,2)]; np=number of points
%
%OUTPUT
%   -points_nm = nm-coordinates of the points [double(np,2)]

function points_nm=D3D_xy2nm(fpath_grd,points_xy,varargin)

%% PARSE

if size(points_xy,2)~=2
    error('The input points must be in rows with coordinates in columns.')
end
if ~exist(fpath_grd,'file')
    error('File %s does not exist',fpath_grd)
end

parin=inputParser;

addOptional(parin,'position','cen')

parse(parin,varargin{:})

pos=parin.Results.position;

%% CALC

%read grid
grid=delft3d_io_grd('read',fpath_grd,'nodatavalue',NaN);
switch pos
    case 'cen'
        % x_cen=grid.cen.x;
        % y_cen=grid.cen.y;
        x_grd=grid.cend.x;
        y_grd=grid.cend.y;
    case 'cor'
        x_grd=grid.cor.x;
        y_grd=grid.cor.y;
end

%find nm
np=size(points_xy,1);
points_nm=NaN(np,2);
for kp=1:np
    dist=(x_grd-points_xy(kp,1)).^2+(y_grd-points_xy(kp,2)).^2;
%     dist=(x_cen-obs_cord(kp,1)).^2+(y_cen-obs_cord(kp,2)).^2;
    [~,idx]=min(dist(:));
    [row,col]=ind2sub(size(dist),idx);
    points_nm(kp,:)=[col,row];
end

%%

% figure
% hold on
% scatter(x_grd(:),y_grd(:),'o')
end %function