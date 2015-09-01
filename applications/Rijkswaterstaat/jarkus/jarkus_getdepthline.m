function DL = jarkus_getdepthline(b,e,depth,year,varargin)
% jarkus_getdepthline calculates the position in distance to RSP
%    of a depthline using jarkus transects. 
%
%   Input:
%     b        = transect-id of begin-position
%     e        = transect-id of end-position
%     depth    = the depth of the depthline
%     year     = the year of which the data is used
%     varargin = optional extra argument plots the depthline
%
%   Output:
%     DL       = for each transect between b and e the position of depth
%                'depth' from year 'year' is given as the distance to 
%                the beach pole (RSP)
%   Example: 
%     DL = jarkus_getdepthline(6000416,6003452,-3,1990,1)
%
% See also: JARKUS, snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%%
%load data from nc-file
url = jarkus_url;
id  = nc_varget(url,'id');
bi  = find(id==b);
ei  = find(id==e);

as  = nc_varget(url,'alongshore',bi-1,ei-bi+1);
X   = nc_varget(url,'cross_shore');
[y, m, d, h, mn, s] = datevec(nc_cf_time(url,'time'));

n  = find(y==year);
z  = squeeze(nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]));
DL = repmat(NaN,size(as));

%calculate distance (from beach pole) for each transect
for i=1:length(z(:,1))
    DL(i)=jarkus_distancetoZ(depth,z(i,:),X);
end

if nargin>4 %make figure to visually see the calculated depthline
    ac = nc_varget(url,'areacode',bi-1,ei-bi+1);
    x  = nc_varget(url,'x',[bi-1,0],[ei-bi+1,-1]);
    y  = nc_varget(url,'y',[bi-1,0],[ei-bi+1,-1]);
    [xRD,yRD] = jarkus_rsp2xy(DL,ac,as);

    scrs=get(0,'ScreenSize');
    figure('position',[5 35 (scrs(3)-5)/2 scrs(4)-105]) % left half of screen
    plot(xRD,yRD,'k','linewidth',2)
    hold on
    pcolor(x,y,z)
    shading flat
    A=axis;
    plotLandboundary('Kaartblad Vaklodingen',1,0)
    axis equal
    axis(A)
    xlabel('x-coordinate')
    ylabel('y-coordinate')
    colorbar
    legend(['Depthline, Z=' num2str(depth)])
end