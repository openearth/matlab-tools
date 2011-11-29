function ddb_editD3DFlowPhysicalParameters
%DDB_EDITD3DFLOWPHYSICALPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowPhysicalParameters
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowPhysicalParameters
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ddb_refreshScreen('Phys. Parameters');

handles=getHandles;

strings={'Constants','Roughness','Viscosity'};
callbacks={@ddb_editD3DFlowConstants,@ddb_editD3DFlowRoughness,@ddb_editD3DFlowViscosity};
k=3;

if handles.Model(md).Input(ad).temperature.include
    k=k+1;
    strings{k}='Heat Flux';
    callbacks{k}=@ddb_editD3DFlowHeatFluxModel;
end

if handles.Model(md).Input(ad).sediments.include
    k=k+1;
    strings{k}='Sediment';
    callbacks{k}=@ddb_editD3DFlowSediment;
    k=k+1;
    strings{k}='Morphology';
    callbacks{k}=@ddb_editD3DFlowMorphology;
end

if handles.Model(md).Input(ad).Wind
    k=k+1;
    strings{k}='Wind';
    callbacks{k}=@ddb_editD3DFlowWind;
end

if handles.Model(md).Input(ad).TidalForces
    k=k+1;
    strings{k}='Tidal Forces';
    callbacks{k}=@ddb_editD3DFlowTidalForces;
end

if handles.Model(md).Input(ad).Roller.Include
    k=k+1;
    strings{k}='Roller Model';
    callbacks{k}=@ddb_editD3DFlowRollerModel;
end

% tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 910 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editD3DFlowConstants;

