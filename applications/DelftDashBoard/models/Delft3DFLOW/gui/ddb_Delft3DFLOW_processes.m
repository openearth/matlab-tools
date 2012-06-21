function ddb_Delft3DFLOW_processes(varargin)
%DDB_DELFT3DFLOW_PROCESSES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_processes(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_processes
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
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.processes');
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'edittracers'}
            ddb_Delft3DFLOW_editTracers;
            % setUIElement('delft3dflow.processes.checktracers');
            % setUIElement('delft3dflow.processes.pushedittracers');
            
            
        case{'editsediments'}
            ddb_Delft3DFLOW_editSediments;
            % setUIElement('delft3dflow.processes.checksediments');
            % setUIElement('delft3dflow.processes.pusheditsediments');
            
        case{'checkconstituents'}
            
        case{'checksediments'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).sediments.include
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','sediments');
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','morphology');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','sediments');
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','morphology');
            %             end
            
        case{'checktemperature'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).temperature.include
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','heatflux');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','heatflux');
            %             end
            
        case{'checkwind'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).wind
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','wind');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','wind');
            %             end
            
        case{'checkroller'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).roller.include
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','roller');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','roller');
            %             end
            
        case{'checktidalforces'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).tidalForces
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','tidalforces');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','tidalforces');
            %             end
            
        case{'checkdredging'}
            %             handles=getHandles;
            %             if handles.Model(md).Input(ad).dredging
            %                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','dredging');
            %             else
            %                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','dredging');
            %             end
            
    end
    
    handles=getHandles;
    
    if handles.Model(md).Input(ad).salinity.include || handles.Model(md).Input(ad).temperature.include || ...
            handles.Model(md).Input(ad).sediments.include || handles.Model(md).Input(ad).tracers
        handles.Model(md).Input(ad).constituents=1;
    else
        handles.Model(md).Input(ad).constituents=0;
    end
    
    setHandles(handles);
    
end



