function ddb_NestingToolbox_DFlowFM_Fews(varargin)
%ddb_NestingToolbox_DFlowFM_Fews  One line description goes here.
%
%   Function to generate output of model setup to be read by FEWS
%
%   Syntax:
%   ddb_NestingToolbox_nestHD1(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD1
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

% $Id: ddb_NestingToolbox_DFlowFM_nest1.m 11901 2015-04-23 19:44:12Z ormondt $
% $Date: 2015-04-23 21:44:12 +0200 (do, 23 apr 2015) $
% $Author: ormondt $
% $Revision: 11901 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_DFlowFM_nest1.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Observation Points in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'select_models'}
            select_models;
        case{'selectcs'}
            selectCS;
        case{'xyn_to_csv'}            
            xyn_to_csv;
        case{'change_mdu'}
            change_mdu;            
    end
end

%%
function select_models

handles=getHandles;

disp('select_models is selected')

%% Overall model is DFLOW-FM

switch handles.toolbox.nesting.fews.detailmodeltype
     
    case{'dflowfm'}        
         %% Model is DFLOW-FM

     case{'dflowfmwave'}
         
         %% Model is DFLOW-FM/SWAN
        
%         if isempty(handles.toolbox.nesting.fews.xynfile)
%             ddb_giveWarning('text','Please first load external forcing file of nested model!');
%             return
%         end
        
        cs.name=handles.toolbox.nesting.fews.detailmodelcsname;
        cs.type=handles.toolbox.nesting.fews.detailmodelcstype;
        
       
end
%%

function xyn_to_csv

handles=getHandles;
disp('xyn_to_csv is selected')

if isempty(handles.toolbox.nesting.fews.xynFile)
    ddb_giveWarning('text','Please first load observation points file!');
    return
end

% read xyn-file
xyn = dflowfm_io_xydata('read' ,handles.toolbox.nesting.fews.xynFile);
% convert to csv-file
clear s output
% attributes
s{1,1} = 'FEWS_ID';
s{1,2} = 'station_name';
s{1,3} = 'X';
s{1,4} = 'Y';
s{1,5} = 'DFLOWFM_ID';
% variables
for j = 1:length(xyn.DATA(:,1))
    s{j+1,1} = xyn.DATA{j,3};
    s{j+1,2} = xyn.DATA{j,3};    
    s{j+1,3} = xyn.DATA{j,1};
    s{j+1,4} = xyn.DATA{j,2};
    s{j+1,5} = xyn.DATA{j,3};
end
T = cell2table(s(2:end,:),'VariableNames',s(1,:));
% write csv-file
handles.toolbox.nesting.dflowfm.csvfile = [handles.toolbox.nesting.fews.xynFile(1:end-4), '.csv'];
writetable(T,handles.toolbox.nesting.dflowfm.csvFile,'Delimiter',';');
clear s T


%%
function change_mdu

handles=getHandles;

disp('change_mdu is selected')

if isempty(handles.toolbox.nesting.fews.mduFile)
    ddb_giveWarning('text','Please first load input file of DflowFM model!');
    return
end

if isempty(handles.toolbox.nesting.fews.zsini)
    ddb_giveWarning('text','Please first insert value for the initial water level!');
    return
end

% read mdu (taken from ddb_readMDU.m)
s = ddb_readDelft3D_keyWordFile(handles.toolbox.nesting.fews.mduFile,'firstcharacterafterdata','#');

% change initial water level
s.geometry.waterlevini = handles.toolbox.nesting.fews.zsini;  %Mdu: # Initial water level

% change swavemodelnr if dflowfm/swan
switch handles.toolbox.nesting.fews.detailmodeltype
     
    case{'dflowfm'}   
        % do nothing
    case{'dflowfmwave'}        
        s.waves.wavemodelnr = 3;
        s.waves.Rouwav      = 'FR84'; %TL: is this strictly necessary to force?
end


% save mdu
%necessary to add to make compatible for ddb_saveMDU:
% s.autostart       = s.model.autostart;
% s.netfile         = s.geometry.netfile;
% s.bathymetryfile  = s.geometry.bathymetryfile;
% s.waterlevinifile = s.geometry.waterlevinifile;
% s.landboundaryfile = s.geometry.landboundaryfile;
% s.thindamfile = s.geometry.thindamfile;
% s.thindykefile = s.geometry.thindykefile;
% s.proflocfile = s.geometry.proflocfile;
% s.profdeffile = s.geometry.profdeffile;
% s.manholefile = s.geometry.manholefile;
% s.waterlevini = s.geometry.waterlevini;
% s.botlevuni = s.geometry.botlevuni;
% s.botlevtype = s.geometry.botlevtype;
% s.anglat = s.geometry.anglat;
% s.conveyance2d = s.geometry.conveyance2d;

%actual saving
% ddb_saveMDU(handles.toolbox.nesting.fews.mduFile,s)
ddb_saveDelft3D_keyWordFile(handles.toolbox.nesting.fews.mduFile, s) %other option bu only writes active keywords

setHandles(handles);




%%
function selectCS

handles=getHandles;

disp('selectCS is selected')

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok
    handles.toolbox.nesting.fews.detailmodelcsname=cs;
    handles.toolbox.nesting.fews.detailmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;

