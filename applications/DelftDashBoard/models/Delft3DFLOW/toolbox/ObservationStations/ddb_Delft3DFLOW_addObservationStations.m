function ddb_Delft3DFLOW_addObservationStations
%DDB_DELFT3DFLOW_ADDOBSERVATIONSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_addObservationStations
%
%   Input:

%
%
%
%
%   Example
%   ddb_Delft3DFLOW_addObservationStations
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

iac=handles.Toolbox(tb).Input.activedatabase;
%stationNames=handles.Toolbox(tb).Input.database(iac).idCodes;

xg=handles.Model(md).Input(ad).gridX;
yg=handles.Model(md).Input(ad).gridY;

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

n=0;

x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
y=handles.Toolbox(tb).Input.database(iac).yLocLocal;

x=[x-360 x x+360];
y=[y y y];
k=0;
for i=1:3
    for j=1:length(handles.Toolbox(tb).Input.database(iac).stationids)
        k=k+1;
        stationNames{k}=handles.Toolbox(tb).Input.database(iac).stationids{j};
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
    [m,n]=findgridcell(posx,posy,xg,yg);
    [m,n]=CheckDepth(m,n,handles.Model(md).Input(ad).depthZ);
    for i=1:length(m)
        if m(i)>0
            nrp=nrp+1;
            istation(nrp)=istat(i);
            mm(nrp)=m(i);
            nn(nrp)=n(i);
            posx2(nrp)=posx(i);
            posy2(nrp)=posy(i);
        end
    end
end

for i=1:nrp
    
    k=istation(i);
    
    shortName=stationNames{k};
    nobs=handles.Model(md).Input(ad).nrObservationPoints;
    Names{1}='';
    for k=1:nobs
        Names{k}=handles.Model(md).Input(ad).observationPoints(k).name;
    end
    
    if isempty(strmatch(shortName,Names,'exact'))
        nobs=nobs+1;
        handles.Model(md).Input(ad).observationPoints(nobs).M=mm(i);
        handles.Model(md).Input(ad).observationPoints(nobs).N=nn(i);
        handles.Model(md).Input(ad).observationPoints(nobs).x=posx2(i);
        handles.Model(md).Input(ad).observationPoints(nobs).y=posy2(i);
        handles.Model(md).Input(ad).observationPoints(nobs).name=shortName;
        handles.Model(md).Input(ad).observationPointNames{nobs}=shortName;
        Names{nobs}=shortName;
    end
    
    handles.Model(md).Input(ad).nrObservationPoints=nobs;
    
end

if nrp>0
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);
end

setHandles(handles);


