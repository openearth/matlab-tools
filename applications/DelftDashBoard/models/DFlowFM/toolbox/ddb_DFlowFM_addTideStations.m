function ddb_DFlowFM_addTideStations
%ddb_DFlowFM_addTideStations  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

xmin=min(handles.Model(md).Input(ad).netstruc.nodeX);
xmax=max(handles.Model(md).Input(ad).netstruc.nodeX);
ymin=min(handles.Model(md).Input(ad).netstruc.nodeY);
ymax=max(handles.Model(md).Input(ad).netstruc.nodeY);

n=0;

x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
y=handles.Toolbox(tb).Input.database(iac).yLocLocal;

x=[x-360 x x+360];
y=[y y y];
k=0;
for i=1:3
    for j=1:length(handles.Toolbox(tb).Input.database(iac).stationShortNames)
        k=k+1;
        stationNames{k}=handles.Toolbox(tb).Input.database(iac).stationShortNames{j};
        stationIDs{k}=handles.Toolbox(tb).Input.database(iac).idCodes{j};
    end
end

ns=length(x);

% First find points within grid bounding box
for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
            y(i)>ymin && y(i)<ymax
        n=n+1;
        posx(n)=x(i);
        posy(n)=y(i);
        name{n}=stationNames{i};
        istat(n)=i;
    end
end

% Find stations within grid
nrp=0;
if ~isempty(posx)
    for i=1:length(posx)
        nrp=nrp+1;
        istation(nrp)=istat(i);
        posx2(nrp)=posx(i);
        posy2(nrp)=posy(i);
    end
end

for i=1:nrp
    
    k=istation(i);
    stationname=stationNames{k};
    stationid=stationIDs{k};

    nobs=handles.Model(md).Input(ad).nrobservationpoints;

    names{1}='';
    for n=1:nobs
        names{n}=handles.Model(md).Input(ad).observationpoints(n).name;
    end

    if handles.Toolbox(tb).Input.showstationnames
        name=justletters(stationname);
        name=name(1:min(length(name),20));
    else
        name=stationid;
    end

    % Check if station with this name already exists
    if isempty(strmatch(name,names,'exact'))
        
        nobs=nobs+1;
        handles.Model(md).Input(ad).observationpoints(nobs).x=posx2(i);
        handles.Model(md).Input(ad).observationpoints(nobs).y=posy2(i);
        handles.Model(md).Input(ad).observationpoints(nobs).name=name;
        handles.Model(md).Input(ad).observationpointnames{nobs}=name;

%         % Add some extra information for CoSMoS toolbox
%         % First find station again
%         ist=strmatch(stationid,handles.Toolbox(tb).Input.database(iac).stationids,'exact');
%         handles.Model(md).Input(ad).observationPoints(nobs).longname=handles.Toolbox(tb).Input.database(iac).stationnames{ist};
%         handles.Model(md).Input(ad).observationPoints(nobs).type='observationstation';
%         handles.Model(md).Input(ad).observationPoints(nobs).source=handles.Toolbox(tb).Input.database(iac).name;
%         handles.Model(md).Input(ad).observationPoints(nobs).id=stationid;
        
    end
    
    handles.Model(md).Input(ad).nrobservationpoints=nobs;
    
end

if nrp>0
     handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','visible',1,'active',0);
end

setHandles(handles);
