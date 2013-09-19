function ddb_DFlowFM_observationPoints(varargin)
%ddb_DFlowFM_observationPoints  One line description goes here.

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

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addobservationpoint=0;
    handles.Model(md).Input(ad).selectobservationpoint=0;
    handles.Model(md).Input(ad).changeobservationpoint=0;
    handles.Model(md).Input(ad).deleteobservationpoint=0;
    handles=ddb_DFlowFM_plotObservationPoints(handles,'update','active',1);
    setHandles(handles);    
else
    
    opt=varargin{1};

    % Default cloud behavior
    h=handles.Model(md).Input(ad).observationpointshandle;
    clearInstructions;
    
    switch(lower(opt))
        
        case{'add'}
            % Click Add in GUI
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            handles.Model(md).Input(ad).changeobservationpoint=0;
            if handles.Model(md).Input(ad).addobservationpoint
                gui_clickpoint('xy','callback',@addObservationPoint,'multiple',1);
                setInstructions({'','','Click point on map for new observation point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
            end
            setHandles(handles);
            
        case{'deletefromlist'}
            % Click Delete From List in GUI
            handles.Model(md).Input(ad).addobservationpoint=0;
            handles.Model(md).Input(ad).changeobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            % Delete observation point selected from list
            handles=deleteObservationPoint(handles);
            setHandles(handles);

        case{'deletefrommap'}
            % Click Delete From Map in GUI
            handles.Model(md).Input(ad).addobservationpoint=0;
            handles.Model(md).Input(ad).changeobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            if handles.Model(md).Input(ad).deleteobservationpoint
                setInstructions({'','','Select observation point to delete from map'});
            end
            setHandles(handles);
            
        case{'change'}
            % Click Change in GUI
            handles.Model(md).Input(ad).addobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            if handles.Model(md).Input(ad).changeobservationpoint
                setInstructions({'','','Select observation point on map to change'});
            end
            setHandles(handles);
            
        case{'edit'}
            % Edit something in GUI
            handles.Model(md).Input(ad).addobservationpoint=0;
            handles.Model(md).Input(ad).changeobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            n=handles.Model(md).Input(ad).activeobservationpoint;
            name=handles.Model(md).Input(ad).observationpoints(n).name;
            handles.Model(md).Input(ad).observationpointnames{n}=name;
            h=handles.Model(md).Input(ad).observationpointshandle;
            gui_pointcloud(h,'change','text',handles.Model(md).Input(ad).observationpointnames);
            setHandles(handles);
            
        case{'selectfromlist'}
            handles.Model(md).Input(ad).addobservationpoint=0;
            handles.Model(md).Input(ad).changeobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            % Delete selected observation point next time delete is clicked
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            h=handles.Model(md).Input(ad).observationpointshandle;
            gui_pointcloud(h,'change','activepoint',handles.Model(md).Input(ad).activeobservationpoint);
            setHandles(handles);
            clearInstructions;

        case{'selectfrommap'}
            iac=varargin{3};
            handles.Model(md).Input(ad).activeobservationpoint=iac;
            if handles.Model(md).Input(ad).deleteobservationpoint
                % Delete selected point
                handles=deleteObservationPoint(handles);
            elseif handles.Model(md).Input(ad).changeobservationpoint
                % Change selected point
                gui_clickpoint('xy','callback',@addObservationPoint,'multiple',0);
                setInstructions({'','','Click new point on map for this observation point'});
            end
            setHandles(handles);
            
        case{'openfile'}
            handles.Model(md).Input(ad).addobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            handles.Model(md).Input(ad).changeobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            handles=ddb_DFlowFM_readObsFile(handles,ad);
            handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
            setHandles(handles);
            
        case{'savefile'}
            handles.Model(md).Input(ad).addobservationpoint=0;
            set(gcf, 'windowbuttondownfcn',[]);
            handles.Model(md).Input(ad).changeobservationpoint=0;
            handles.Model(md).Input(ad).deleteobservationpoint=0;
            ddb_DFlowFM_saveObsFile(handles,ad);
            
    end
end

refreshObservationPoints;

%%
function addObservationPoint(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;

if handles.Model(md).Input(ad).changeobservationpoint
    iac=handles.Model(md).Input(ad).activeobservationpoint;
    set(gcf, 'windowbuttondownfcn',[]);
else
    % Add mode
    handles.Model(md).Input(ad).nrobservationpoints=handles.Model(md).Input(ad).nrobservationpoints+1;
    iac=handles.Model(md).Input(ad).nrobservationpoints;
    handles.Model(md).Input(ad).observationpoints(iac).name=['obspoint ' num2str(iac)];
    handles.Model(md).Input(ad).observationpointnames{iac}=handles.Model(md).Input(ad).observationpoints(iac).name;
end

handles.Model(md).Input(ad).observationpoints(iac).x=x1;
handles.Model(md).Input(ad).observationpoints(iac).y=y1;
handles.Model(md).Input(ad).activeobservationpoint=iac;

handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
setHandles(handles);

refreshObservationPoints;

%%
function handles=deleteObservationPoint(handles)

nrobs=handles.Model(md).Input(ad).nrobservationpoints;

if nrobs>0
    iac=handles.Model(md).Input(ad).activeobservationpoint;
    handles=ddb_DFlowFM_plotObservationPoints(handles,'delete','observationpoints');
    if nrobs>1
        handles.Model(md).Input(ad).observationpoints=removeFromStruc(handles.Model(md).Input(ad).observationpoints,iac);
        handles.Model(md).Input(ad).observationpointnames=removeFromCellArray(handles.Model(md).Input(ad).observationpointnames,iac);
    else
        handles.Model(md).Input(ad).observationpointnames={''};
        handles.Model(md).Input(ad).activeobservationpoint=1;
        handles.Model(md).Input(ad).observationpoints(1).x=NaN;
        handles.Model(md).Input(ad).observationpoints(1).y=NaN;
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.Model(md).Input(ad).nrobservationpoints=nrobs-1;
    handles.Model(md).Input(ad).activeobservationpoint=max(iac,1);
    handles=ddb_DFlowFM_plotObservationPoints(handles,'plot','active',1);
    setHandles(handles);
    refreshObservationPoints;
end

%%
function refreshObservationPoints
gui_updateActiveTab;
