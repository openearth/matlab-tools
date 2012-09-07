function [times u v] = generateVelocitiesFromFile(flow, openBoundaries, opt)
%GENERATEVELOCITIESFROMFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [times u v] = generateVelocitiesFromFile(flow, openBoundaries, opt)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%
%   Output:
%   times          =
%   u              =
%   v              =
%
%   Example
%   generateVelocitiesFromFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;

nr=length(openBoundaries);

for i=1:nr
    dp(i,1)=-openBoundaries(i).depth(1);
    dp(i,2)=-openBoundaries(i).depth(2);
end

if strcmpi(flow.vertCoord,'z')
    dplayer=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=getLayerDepths(dp,flow.thick);
end

% First interpolate data onto boundaries
for i=1:nr
    
    % End A
    
    x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
    y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));
    alphau(i,1)=openBoundaries(i).alphau(1);
    alphav(i,1)=openBoundaries(i).alphav(1);
    
    % End B
    x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
    y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));
    alphau(i,2)=openBoundaries(i).alphau(2);
    alphav(i,2)=openBoundaries(i).alphav(2);
    
end

if isfield(flow,'coordSysType')
    if ~strcmpi(flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [x,y]=convertCoordinates(x,y,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    end
    x=mod(x,360);
end

minx=min(min(x));
maxx=max(max(x));
miny=min(min(y));
maxy=max(max(y));

% Find available times
flist=dir([opt.current.BC.datafolder filesep opt.current.BC.dataname '.current_u.*.mat']);
for i=1:length(flist)
    tstr=flist(i).name(end-17:end-4);
    times(i)=datenum(tstr,'yyyymmddHHMMSS');
end

% Longitudes
su=load([opt.current.BC.datafolder filesep opt.current.BC.dataname '.current_u.' datestr(times(1),'yyyymmddHHMMSS') '.mat']);
sv=load([opt.current.BC.datafolder filesep opt.current.BC.dataname '.current_v.' datestr(times(1),'yyyymmddHHMMSS') '.mat']);
su.lon=mod(su.lon,360);
sv.lon=mod(sv.lon,360);
x=mod(x,360);

ilon1=find(su.lon<minx,1,'last');
ilon2=find(su.lon>maxx,1,'first');
ilat1=find(su.lat<miny,1,'last');
ilat2=find(su.lat>maxy,1,'first');

% Find required times
it0=find(times<=t0, 1, 'last' );
it1=find(times>=t1, 1, 'first' );
times=times(it0:it1);

nt=0;

    for it=it0:it1
        
        nt=nt+1;
        
        % Loop through all files
        
        disp(['Reading files ' num2str(nt) ' of ' num2str(it1-it0+1)]);
        
        su=load([opt.current.BC.datafolder filesep opt.current.BC.dataname '.current_u.' datestr(times(nt),'yyyymmddHHMMSS') '.mat']);
        sv=load([opt.current.BC.datafolder filesep opt.current.BC.dataname '.current_v.' datestr(times(nt),'yyyymmddHHMMSS') '.mat']);
        
        su.lon=su.lon(ilon1:ilon2);
        su.lat=su.lat(ilat1:ilat2);
        su.data=su.data(ilat1:ilat2,ilon1:ilon2,:);
        sv.lon=sv.lon(ilon1:ilon2);
        sv.lat=sv.lat(ilat1:ilat2);
        sv.data=sv.data(ilat1:ilat2,ilon1:ilon2,:);
        su.lon=mod(su.lon,360);
        sv.lon=mod(sv.lon,360);
        
        uu=interpolate3D(x,y,dplayer,su,'u');
        vv=interpolate3D(x,y,dplayer,sv,'v');
        
        for j=1:nr
            
            tua=squeeze(uu(j,1,:))';
            tub=squeeze(uu(j,2,:))';
            tva=squeeze(vv(j,1,:))';
            tvb=squeeze(vv(j,2,:))';
            
            ua = tua.*cos(alphau(j,1)) + tva.*sin(alphau(j,1));
            ub = tub.*cos(alphau(j,2)) + tvb.*sin(alphau(j,2));
            va = tua.*cos(alphav(j,1)) + tva.*sin(alphav(j,1));
            vb = tub.*cos(alphav(j,2)) + tvb.*sin(alphav(j,2));
            
            u0(j,1,:,nt)=ua;
            u0(j,2,:,nt)=ub;
            v0(j,1,:,nt)=va;
            v0(j,2,:,nt)=vb;
            
        end
    end

clear s sv

t=t0:dt/1440:t1;
for j=1:nr
    for k=1:flow.KMax
        u(j,1,k,:) = spline(times,squeeze(u0(j,1,k,:)),t);
        u(j,2,k,:) = spline(times,squeeze(u0(j,2,k,:)),t);
        v(j,1,k,:) = spline(times,squeeze(v0(j,1,k,:)),t);
        v(j,2,k,:) = spline(times,squeeze(v0(j,2,k,:)),t);
    end
end
times=t;

