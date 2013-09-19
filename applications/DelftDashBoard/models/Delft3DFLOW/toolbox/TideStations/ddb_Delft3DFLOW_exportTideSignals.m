function ddb_Delft3DFLOW_exportTideSignals
%DDB_DELFT3DFLOW_EXPORTTIDESIGNALS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_exportTideSignals
%
%   Input:

%
%
%
%
%   Example
%   ddb_Delft3DFLOW_exportTideSignals
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles=getHandles;

posx=[];

iac=handles.Toolbox(tb).Input.activeDatabase;
names=handles.Toolbox(tb).Input.database(iac).stationShortNames;

xg=handles.Model(md).Input(ad).gridX;
yg=handles.Model(md).Input(ad).gridY;

if isempty(xg)
    ddb_giveWarning('text','Please first load or generate a grid!');
    return
end

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(handles.Toolbox(tb).Input.database(iac).xLoc);
n=0;

x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;

wb = awaitbar(0,'Finding stations...');

% First find points within grid bounding box
for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
            y(i)>ymin && y(i)<ymax
        n=n+1;
        posx(n)=x(i);
        posy(n)=y(i);
        name{n}=names{i};
        istat(n)=i;
    end
end

% Find stations within grid
nrp=0;
if ~isempty(posx)
    [m,n]=findgridcell(posx,posy,xg,yg);
    for i=1:length(m)
        if m(i)>0
            nrp=nrp+1;
            istation(nrp)=istat(i);
        end
    end
end

for i=1:nrp
    
    k=istation(i);
    
    stationName=handles.Toolbox(tb).Input.database(iac).stationList{k};
    
    str=['Station ' stationName ' - ' num2str(i) ' of ' num2str(nrp) ' ...'];
    [hh,abort2]=awaitbar(i/(nrp),wb,str);
    
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
    
    t0=handles.Toolbox(tb).Input.startTime;
    t1=handles.Toolbox(tb).Input.stopTime;
    dt=handles.Toolbox(tb).Input.timeStep/1440;
    tim=t0:dt:t1;
    
    % Read data from nc file
    fname=[handles.Toolbox(tb).dataDir handles.Toolbox(tb).Input.database(iac).shortName '.nc'];
    ncomp=length(handles.Toolbox(tb).Input.database(iac).components);
    amp00=nc_varget(fname,'amplitude',[0 k-1],[ncomp 1]);
    phi00=nc_varget(fname,'phase',[0 k-1],[ncomp 1]);
    
    components=[];
    amplitudes=[];
    phases=[];
    
    % Find non-zero amplitudes
    ii=find(amp00~=0);
    for j=1:length(ii)
        ik=ii(j);
        components{j}=handles.Toolbox(tb).Input.database(iac).components{ik};
        amplitudes(j)=amp00(ik);
        phases(j)=phi00(ik);
    end
    
    latitude=handles.Toolbox(tb).Input.database(iac).y(k);

    timezonestation=handles.Toolbox(tb).Input.database(iac).timezone(k);

    wl=makeTidePrediction(tim,components,amplitudes,phases,latitude,'timezone',handles.Toolbox(tb).Input.timeZone,...
        'maincomponents',handles.Toolbox(tb).Input.usemaincomponents,'timezonestation',timezonestation);
    wl=wl+handles.Toolbox(tb).Input.verticalOffset;
    
    if handles.Toolbox(tb).Input.showstationnames
        fname=[handles.Toolbox(tb).Input.database(iac).stationShortNames{k}];
    else
        fname=[handles.Toolbox(tb).Input.database(iac).idCodes{k}];
    end
    exportTEK(wl',tim',[fname '.tek'],stationName);

    s.station(i).name=fname;
    s.station(i).longname=handles.Toolbox(tb).Input.database(iac).stationList{k};
    s.station(i).x=handles.Toolbox(tb).Input.database(iac).xLocLocal(k);
    s.station(i).y=handles.Toolbox(tb).Input.database(iac).yLocLocal(k);
    s.station(i).component=components;
    s.station(i).amplitude=amplitudes;
    s.station(i).phase=phases;
    
    
    
end

save(['allstations_' handles.Toolbox(tb).Input.database(iac).shortName '.mat'],'-struct','s');

try
    close(wb);
end

