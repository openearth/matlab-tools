function ddb_TropicalCycloneToolbox_setParameters(varargin)
%DDB_TROPICALCYCLONETOOLBOX_SETPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCycloneToolbox_setParameters(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TropicalCycloneToolbox_setParameters
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
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
    handles=getHandles;
    setUIElements('tropicalcyclonepanel.parameters');
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
    end
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'computecyclone'}
            computeCyclone;
        case{'drawtrack'}
            drawTrack;
        case{'edittracktable'}
            editTrackTable;
        case{'loaddata'}
            loadDataFile;
        case{'savedata'}
            saveDataFile;
        case{'importtrack'}
            importTrack;
        case{'selectquadrantoption'}
            selectQuadrantOption;
        case{'downloadtrack'}
            downloadTrackData;
    end
end

%%
function drawTrack
handles=getHandles;

[handles,ok]=ddb_getInitialCycloneTrackParameters(handles);

if ok
    
    setInstructions({'','Click on map to draw cyclone track','Use right-click to end cyclone track'});
    
    h=findobj(gcf,'Tag','cycloneTrack');
    if ~isempty(h)
        delete(h);
    end
    
    ddb_zoomOff;
    UIPolyline(gca,'draw','Tag','cycloneTrack','Marker','o','Callback',@ddb_changeCycloneTrack,'DoubleClickCallback',@ddb_selectCyclonePoint,'closed',0);
    handles.Toolbox(tb).Input.newTrack=1;
    
    setHandles(handles);
    
end

%%
function selectQuadrantOption

handles=getHandles;

if strcmpi(handles.Toolbox(tb).Input.quadrantOption,'uniform')
    handles.Toolbox(tb).Input.quadrant=1;
end

handles=ddb_setTrackTableValues(handles);

setHandles(handles);

%%
function selectQuadrant

handles=getHandles;
handles=ddb_setTrackTableValues(handles);
setHandles(handles);

function loadDataFile

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.cyc', 'Select Cyclone File','');

if filename==0
    return
end

filename=[pathname filename];
handles.Toolbox(tb).Input.cycloneFile=[pathname filename];
handles=ddb_readCycloneFile(handles,filename);

handles.Toolbox(tb).Input.quadrant=1;

handles=ddb_setTrackTableValues(handles);

setHandles(handles);

%     ddb_updateTrackTables;

setUIElement('tropicalcyclonepanel.parameters.editname');
setUIElement('tropicalcyclonepanel.parameters.editradius');
setUIElement('tropicalcyclonepanel.parameters.editradialbins');
setUIElement('tropicalcyclonepanel.parameters.editdirectionalbins');
setUIElement('tropicalcyclonepanel.parameters.selectquadrant');
setUIElement('tropicalcyclonepanel.parameters.radioperquadrant');
setUIElement('tropicalcyclonepanel.parameters.radiouniform');

ddb_plotCycloneTrack;

%%
function saveDataFile

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.cyc', 'Select Cyclone File','');
if filename==0
    return
end
filename=[pathname filename];
handles.Toolbox(tb).Input.cycloneFile=filename;
setHandles(handles);
ddb_saveCycloneFile(handles,filename);

%%
function downloadTrackData
handles=getHandles;
switch lower(handles.Toolbox(tb).Input.downloadLocation)
    case{'unisysbesttracks'}
        web http://weather.unisys.com/hurricane -browser
    case{'jtwcbesttracks'}
        web http://www.usno.navy.mil/NOOC/nmfc-ph/RSS/jtwc/best_tracks/ -browser
    case{'jtwccurrentcyclones'}
        web http://www.usno.navy.mil/JTWC/ -browser
end

%%
function importTrack

handles=getHandles;

switch lower(handles.Toolbox(tb).Input.importFormat)
    case{'unisysbesttrack'}
        ext='dat';
    otherwise
        ext='*';
end

[filename, pathname, filterindex] = uigetfile(['*.' ext], 'Select Data File','');
if filename==0
    return
end

try
    
    switch lower(handles.Toolbox(tb).Input.importFormat)
        case{'jtwcbesttrack'}
            tc=readBestTrackJTWC([pathname filename]);
            handles.Toolbox(tb).Input.method=2;
            handles.Toolbox(tb).Input.quadrantOption='perquadrant';
        case{'unisysbesttrack'}
            tc=readBestTrackUnisys([pathname filename]);
            handles.Toolbox(tb).Input.method=4;
            handles.Toolbox(tb).Input.quadrantOption='uniform';
        otherwise
            giveWarning('text','Sorry, present import format not supported!');
            return
    end
    
    handles.Toolbox(tb).Input.quadrant=1;
    
    nt=length(tc.time);
    
    % Set dummy values
    handles.Toolbox(tb).Input.trackT=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackX=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackY=zeros([nt 1]);
    handles.Toolbox(tb).Input.trackVMax=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackPDrop=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackRMax=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR100=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR65=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR50=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackR35=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackA=zeros([nt 4])-999;
    handles.Toolbox(tb).Input.trackB=zeros([nt 4])-999;
    
    k=0;
    for it=1:nt
        
        %        if (tc(it).r34(1))>=0
        
        k=k+1;
        
        handles.Toolbox(tb).Input.trackT(k)=tc.time(it);
        handles.Toolbox(tb).Input.trackX(k)=tc.lon(it);
        handles.Toolbox(tb).Input.trackY(k)=tc.lat(it);
        if isfield(tc,'vmax')
            handles.Toolbox(tb).Input.trackVMax(k,1:4)=tc.vmax(it,:);
        end
        if isfield(tc,'p')
            handles.Toolbox(tb).Input.trackPDrop(k,1:4)=[101200 101200 101200 101200] - tc.p(it,:);
        end
        if isfield(tc,'rmax')
            handles.Toolbox(tb).Input.trackRMax(k,1:4)=tc.rmax(it,:);
        end
        if isfield(tc,'a')
            handles.Toolbox(tb).Input.trackA(k,1:4)=tc.a(it,:);
        end
        if isfield(tc,'b')
            handles.Toolbox(tb).Input.trackB(k,1:4)=tc.b(it,:);
        end
        
        if isfield(tc,'r34')
            handles.Toolbox(tb).Input.trackR35(k,1)=tc.r34(it,1);
            handles.Toolbox(tb).Input.trackR35(k,2)=tc.r34(it,2);
            handles.Toolbox(tb).Input.trackR35(k,3)=tc.r34(it,3);
            handles.Toolbox(tb).Input.trackR35(k,4)=tc.r34(it,4);
        end
        
        if isfield(tc,'r50')
            handles.Toolbox(tb).Input.trackR50(k,1)=tc.r50(it,1);
            handles.Toolbox(tb).Input.trackR50(k,2)=tc.r50(it,2);
            handles.Toolbox(tb).Input.trackR50(k,3)=tc.r50(it,3);
            handles.Toolbox(tb).Input.trackR50(k,4)=tc.r50(it,4);
        end
        
        if isfield(tc,'r64')
            handles.Toolbox(tb).Input.trackR65(k,1)=tc.r64(it,1);
            handles.Toolbox(tb).Input.trackR65(k,2)=tc.r64(it,2);
            handles.Toolbox(tb).Input.trackR65(k,3)=tc.r64(it,3);
            handles.Toolbox(tb).Input.trackR65(k,4)=tc.r64(it,4);
        end
        
        if isfield(tc,'r100')
            handles.Toolbox(tb).Input.trackR100(k,1)=tc.r100(it,1);
            handles.Toolbox(tb).Input.trackR100(k,2)=tc.r100(it,2);
            handles.Toolbox(tb).Input.trackR100(k,3)=tc.r100(it,3);
            handles.Toolbox(tb).Input.trackR100(k,4)=tc.r100(it,4);
        end
        
        %     end
    end
    
    if k>0
        
        handles.Toolbox(tb).Input.nrTrackPoints=k;
        handles.Toolbox(tb).Input.name=tc.name;
        
        handles=ddb_setTrackTableValues(handles);
        
        setHandles(handles);
        
        setUIElement('tropicalcyclonepanel.parameters.editname');
        setUIElement('tropicalcyclonepanel.parameters.radioperquadrant');
        setUIElement('tropicalcyclonepanel.parameters.radiouniform');
        setUIElement('tropicalcyclonepanel.parameters.selectmethod');
        
        ddb_plotCycloneTrack;
        
    end
    
catch
    GiveWarning('text','An error occured while reading cyclone data');
end

%%
function computeCyclone

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.spw', 'Select Spiderweb File','');
if filename==0
    return
else
    try
        wb = waitbox('Generating Spiderweb Wind Field ...');%pause(0.1);
        handles=ddb_computeCyclone(handles,filename);
        close(wb);
        setHandles(handles);
    catch
        close(wb);
        giveWarning('text','An error occured while generating spiderweb wind file');
    end
end

