function openBoundaries = generateTransportBoundaryConditions(flow, openBoundaries, opt, par, ii, dplayer)
%GENERATETRANSPORTBOUNDARYCONDITIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = generateTransportBoundaryConditions(flow, openBoundaries, opt, par, ii, dplayer)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%   par            =
%   ii             =
%   dplayer        =
%
%   Output:
%   openBoundaries =
%
%   Example
%   generateTransportBoundaryConditions
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
dt=opt.bccTimeStep;

switch opt.(par)(ii).BC.source
    case 4
        % Constant
        pars=[0 opt.(par)(ii).BC.constant]';
    case 5
        % Profile
%        pars=opt.(par)(ii).BC.profile';
        pars=load(opt.(par)(ii).BC.profileFile);
        pars=pars';
end

switch opt.(par)(ii).BC.source
    
    case{4,5}
        % Constant or profile
        depths=pars(1,:);
        vals=pars(2,:);
        depths=[-100000 depths 100000];
        vals =[vals(1) vals vals(end)];
        val=interp1(depths,vals,dplayer);
        
        for j=1:length(openBoundaries)
            openBoundaries(j).(par)(ii).nrTimeSeries=2;
            openBoundaries(j).(par)(ii).timeSeriesT=[t0;t1];
            if flow.KMax>1
                openBoundaries(j).(par)(ii).profile='3d-profile';
            else
                openBoundaries(j).(par)(ii).profile='uniform';
            end
            ta=squeeze(val(j,1,:))';
            tb=squeeze(val(j,2,:))';
            ta=[ta;ta];
            tb=[tb;tb];
            if strcmpi(flow.vertCoord,'z')
                ta=fliplr(ta);
                tb=fliplr(tb);
            end
            openBoundaries(j).(par)(ii).timeSeriesA=ta;
            openBoundaries(j).(par)(ii).timeSeriesB=tb;
        end
        
    case{2}
        % File
        for i=1:length(openBoundaries)
            x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
            y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));
            x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
            y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));
        end
        
        if isfield(flow,'coordSysType')
            if ~strcmpi(flow.coordSysType,'geographic')
                % First convert grid to WGS 84
                [x,y]=convertCoordinates(x,y,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
            end
            x=mod(x,360);
        end
        
        x=mod(x,360);
        
        minx=min(min(x));
        maxx=max(max(x));
        miny=min(min(y));
        maxy=max(max(y));
        
        % Find available times
        flist=dir([opt.(par)(ii).BC.datafolder filesep opt.(par)(ii).BC.dataname '.' par '.*.mat']);
        for i=1:length(flist)
            tstr=flist(i).name(end-17:end-4);
            times(i)=datenum(tstr,'yyyymmddHHMMSS');
        end
        
        it0=find(times<=t0, 1, 'last' );
        it1=find(times>=t1, 1, 'first' );
        
        if isempty(it0)
            it0=1;
        end
        if isempty(it1)
            it1=length(times);
        end
        times=times(it0:it1);
        
        for j=1:length(openBoundaries)
            openBoundaries(j).(par)(ii).nrTimeSeries=0;
            openBoundaries(j).(par)(ii).timeSeriesT=[];
            openBoundaries(j).(par)(ii).profile='3d-profile';
            openBoundaries(j).(par)(ii).timeSeriesA=[];
            openBoundaries(j).(par)(ii).timeSeriesB=[];
        end
        
        nt=0;
        
        for it=it0:it1
            
            nt=nt+1;
            
            disp(['      Time step ' num2str(nt) ' of ' num2str(it1-it0+1)]);
            
            s=load([opt.(par)(ii).BC.datafolder filesep opt.(par)(ii).BC.dataname '.' par '.' datestr(times(nt),'yyyymmddHHMMSS') '.mat']);

            s.lon=mod(s.lon,360);
            
            ilon1=find(s.lon<minx,1,'last');
            ilon2=find(s.lon>maxx,1,'first');
            ilat1=find(s.lat<miny,1,'last');
            ilat2=find(s.lat>maxy,1,'first');
            
            s.lon=s.lon(ilon1:ilon2);
            s.lon=mod(s.lon,360);
            s.lat=s.lat(ilat1:ilat2);
            s.data=s.data(ilat1:ilat2,ilon1:ilon2,:);
            
            t=times(nt);
            data=interpolate3D(x,y,dplayer,s);
            
            for j=1:length(openBoundaries)
                ta=squeeze(data(j,1,:))';
                tb=squeeze(data(j,2,:))';
                openBoundaries(j).(par)(ii).nrTimeSeries=nt;
                openBoundaries(j).(par)(ii).timeSeriesT=[openBoundaries(j).(par)(ii).timeSeriesT;t];
                openBoundaries(j).(par)(ii).timeSeriesA=[openBoundaries(j).(par)(ii).timeSeriesA;ta];
                openBoundaries(j).(par)(ii).timeSeriesB=[openBoundaries(j).(par)(ii).timeSeriesB;tb];
            end
        end
        
        t=t0:dt/1440:t1;
        for j=1:length(openBoundaries)
            ta=[];
            tb=[];
            for k=1:flow.KMax
                ta(:,k) = spline(openBoundaries(j).(par)(ii).timeSeriesT,openBoundaries(j).(par)(ii).timeSeriesA(:,k),t);
                tb(:,k) = spline(openBoundaries(j).(par)(ii).timeSeriesT,openBoundaries(j).(par)(ii).timeSeriesB(:,k),t);
            end
            openBoundaries(j).(par)(ii).timeSeriesT = t;
            openBoundaries(j).(par)(ii).timeSeriesA = ta;
            openBoundaries(j).(par)(ii).timeSeriesB = tb;
            openBoundaries(j).(par)(ii).nrTimeSeries=length(t);
            
            if strcmpi(flow.vertCoord,'z')
                openBoundaries(j).(par)(ii).timeSeriesA=flipdim(openBoundaries(j).(par)(ii).timeSeriesA,2);
                openBoundaries(j).(par)(ii).timeSeriesB=flipdim(openBoundaries(j).(par)(ii).timeSeriesB,2);
            end
        end
        
end



