function ddb_DFlowFM_crossSections(varargin)
%ddb_DFlowFM_crossSections  One line description goes here.

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

ddb_zoomOff;

if isempty(varargin)
    handles=getHandles;
    ddb_refreshScreen;
    handles=ddb_DFlowFM_plotCrossSections(handles,'update','active',1);
    setHandles(handles);    
else
    
    opt=varargin{1};

    clearInstructions;
    
    switch(lower(opt))

        case{'add'}
            drawCrossSection;

        case{'selectfromlist'}
            selectFromList;
            
        case{'deletefromlist'}
            deleteCrossSection;

        case{'edit'}
            editCrossSection;

        case{'changecrosssection'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            changeCrossSection(h,x,y);
            
        case{'openfile'}
            handles=getHandles;
            handles.Model(md).Input.crosssections=ddb_DFlowFM_readCrsFile(handles.Model(md).Input.crsfile);
            handles.Model(md).Input.nrcrosssections=length(handles.Model(md).Input.crosssections);
            handles=updateNames(handles);
            handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
            setHandles(handles);
            
        case{'savefile'}
            handles=getHandles;
            ddb_DFlowFM_saveCrsFile(handles.Model(md).Input.crsfile,handles.Model(md).Input.crosssections);

    end
end

refreshCrossSections;

%%
function drawCrossSection

handles=getHandles;
% Click Add in GUI
handles.Model(md).Input(ad).deletecrosssection=0;
ddb_zoomOff;
setInstructions({'','','Draw cross section'});
gui_polyline('draw','tag','dflowfmcrosssection','Marker','o','createcallback',@addCrossSection,'changecallback',@changeCrossSection,'closed',0, ...
    'color','g','markeredgecolor','r','markerfacecolor','r');
setHandles(handles);

%%
function addCrossSection(h,x,y)

clearInstructions;

handles=getHandles;

% Add mode
handles.Model(md).Input(ad).nrcrosssections=handles.Model(md).Input(ad).nrcrosssections+1;
iac=handles.Model(md).Input(ad).nrcrosssections;
handles.Model(md).Input(ad).crosssections(iac).name=['crosssection ' num2str(iac)];
handles.Model(md).Input(ad).crosssectionnames{iac}=handles.Model(md).Input(ad).crosssections(iac).name;

handles.Model(md).Input(ad).crosssections(iac).x=x;
handles.Model(md).Input(ad).crosssections(iac).y=y;
handles.Model(md).Input(ad).crosssections(iac).handle=h;
handles.Model(md).Input(ad).activecrosssection=iac;

handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);

setHandles(handles);

refreshCrossSections;

%%
function changeCrossSection(h,x,y)

% Cross section changed on map

handles=getHandles;

for ii=1:handles.Model(md).Input(ad).nrcrosssections
    if handles.Model(md).Input(ad).crosssections(ii).handle==h
        iac=ii;
        break;
    end
end

handles.Model(md).Input(ad).crosssections(iac).x=x;
handles.Model(md).Input(ad).crosssections(iac).y=y;
handles.Model(md).Input(ad).activecrosssection=iac;

handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);

setHandles(handles);

refreshCrossSections;

%%
function deleteCrossSection

clearInstructions;

handles=getHandles;

nrobs=handles.Model(md).Input(ad).nrcrosssections;

if nrobs>0
    iac=handles.Model(md).Input(ad).activecrosssection;
    handles=ddb_DFlowFM_plotCrossSections(handles,'delete','crosssections');
    if nrobs>1
        handles.Model(md).Input(ad).crosssections=removeFromStruc(handles.Model(md).Input(ad).crosssections,iac);
        handles.Model(md).Input(ad).crosssectionnames=removeFromCellArray(handles.Model(md).Input(ad).crosssectionnames,iac);
    else
        handles.Model(md).Input(ad).crosssectionnames={''};
        handles.Model(md).Input(ad).activecrosssection=1;
        handles.Model(md).Input(ad).crosssections(1).name='';
        handles.Model(md).Input(ad).crosssections(1).x=0;
        handles.Model(md).Input(ad).crosssections(1).y=0;
    end
    if iac==nrobs
        iac=max(nrobs-1,1);
    end
    handles.Model(md).Input(ad).nrcrosssections=nrobs-1;
    handles.Model(md).Input(ad).activecrosssection=iac;
    handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
    setHandles(handles);
    refreshCrossSections;
end

%%
function editCrossSection
clearInstructions;
handles=getHandles;
handles=updateNames(handles);
handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
setHandles(handles);

%%
function selectFromList
clearInstructions;
handles=getHandles;
handles=ddb_DFlowFM_plotCrossSections(handles,'plot','active',1);
setHandles(handles);

%%
function handles=updateNames(handles)
handles.Model(md).Input.crosssectionnames=[];
for ib=1:handles.Model(md).Input.nrcrosssections
    handles.Model(md).Input.crosssectionnames{ib}=handles.Model(md).Input.crosssections(ib).name;
end

%%
function refreshCrossSections
gui_updateActiveTab;
