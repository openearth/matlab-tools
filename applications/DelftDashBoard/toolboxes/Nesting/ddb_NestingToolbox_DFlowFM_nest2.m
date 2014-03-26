function ddb_NestingToolbox_DFlowFM_nest2(varargin)
%DDB_NESTINGTOOLBOX_NESTHD2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD2(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD2
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
    setInstructions({'Click Run Nesting in order to generate boundary conditions for the nested model', ...
        'The overall model simulation must be finished and a history file must be present','The nested model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nesthd2'}
            nestHD2;
    end
end

%%
function nestHD2

handles=getHandles;

if isempty(handles.toolbox.nesting.trihFile)
    ddb_giveWarning('text','Please first load history file of overall model!');
    return
end

hisfile=handles.toolbox.nesting.trihFile;
nestadm=handles.toolbox.nesting.admFile;
z0=handles.toolbox.nesting.zCor;
opt='';
if handles.toolbox.nesting.nestHydro && handles.toolbox.nesting.nestTransport
    opt='both';
elseif handles.toolbox.nesting.nestHydro
    opt='hydro';
elseif handles.toolbox.nesting.nestTransport
    opt='transport';
end
stride=1;

if ~isempty(opt)
    
    % Make structure info for nesthd2
%    bnd=handles.Model(md).Input(ad).openBoundaries;
    bnd=handles.Model(md).Input(ad).boundaries;
    
    % Vertical grid info
%     vertGrid.KMax=handles.Model(md).Input(ad).KMax;
%     vertGrid.layerType=handles.Model(md).Input(ad).layerType;
%     vertGrid.thick=handles.Model(md).Input(ad).thick;
%     vertGrid.zTop=handles.Model(md).Input(ad).zTop;
%     vertGrid.zBot=handles.Model(md).Input(ad).zBot;

    vertGrid=[];

    % Run Nesthd2
    cs=handles.screenParameters.coordinateSystem.type;
    bnd=nesthd2_new('input',handles.Model(md).Input,'openboundaries',bnd,'vertgrid',vertGrid,'hisfile',hisfile, ...
        'admfile',nestadm,'zcor',z0,'stride',stride,'opt',opt,'coordinatesystem',cs,'save','n');
    
    handles.model.dflowfm.domain.boundaries=bnd;

%     zersunif=zeros(2,1);
%     
%     for i=1:length(bnd)
%         
%         if strcmpi(bnd(i).forcing,'T')
%             
%             if handles.toolbox.nesting.nestHydro
%                 % Copy boundary data
%                 % Hydrodynamics
%                 handles.Model(md).Input(ad).openBoundaries(i).nrTimeSeries=length(bnd(i).timeSeriesT);
%                 handles.Model(md).Input(ad).openBoundaries(i).timeSeriesT=bnd(i).timeSeriesT;
%                 handles.Model(md).Input(ad).openBoundaries(i).timeSeriesA=bnd(i).timeSeriesA;
%                 handles.Model(md).Input(ad).openBoundaries(i).timeSeriesB=bnd(i).timeSeriesB;
%                 handles.Model(md).Input(ad).openBoundaries(i).timeSeriesAV=bnd(i).timeSeriesAV;
%                 handles.Model(md).Input(ad).openBoundaries(i).timeSeriesBV=bnd(i).timeSeriesBV;
%                 handles.Model(md).Input(ad).openBoundaries(i).profile=bnd(i).profile;
%             end
%             
%             if handles.toolbox.nesting.nestTransport
%                 % Transport
%                 
%                 % Salinity
%                 
%                 handles.Model(md).Input(ad).openBoundaries(i).salinity.nrTimeSeries=2;
%                 handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
%                 
%                 handles.Model(md).Input(ad).openBoundaries(i).salinity.profile='uniform';
%                 handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesA=zersunif+handles.Model(md).Input(ad).salinity.ICConst;
%                 handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesB=zersunif+handles.Model(md).Input(ad).salinity.ICConst;
%                 
%                 if handles.Model(md).Input(ad).salinity.include
%                     if isfield(bnd(i),'salinity')
%                         handles.Model(md).Input(ad).openBoundaries(i).salinity.nrTimeSeries=length(bnd(i).salinity.timeSeriesT);
%                         handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesT=bnd(i).salinity.timeSeriesT;
%                         handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesA=bnd(i).salinity.timeSeriesA;
%                         handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesB=bnd(i).salinity.timeSeriesB;
%                         handles.Model(md).Input(ad).openBoundaries(i).salinity.profile=bnd(i).salinity.profile;
%                     end
%                 end
%                 
%                 % Temperature
%                 handles.Model(md).Input(ad).openBoundaries(i).temperature.nrTimeSeries=2;
%                 handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
%                 
%                 handles.Model(md).Input(ad).openBoundaries(i).temperature.profile='uniform';
%                 handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesA=zersunif+handles.Model(md).Input(ad).temperature.ICConst;
%                 handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesB=zersunif+handles.Model(md).Input(ad).temperature.ICConst;
%                 
%                 if handles.Model(md).Input(ad).temperature.include
%                     if isfield(bnd(i),'temperature')
%                         handles.Model(md).Input(ad).openBoundaries(i).temperature.nrTimeSeries=length(bnd(i).temperature.timeSeriesT);
%                         handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesT=bnd(i).temperature.timeSeriesT;
%                         handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesA=bnd(i).temperature.timeSeriesA;
%                         handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesB=bnd(i).temperature.timeSeriesB;
%                         handles.Model(md).Input(ad).openBoundaries(i).temperature.profile=bnd(i).temperature.profile;
%                     end
%                 end
%                 
%                 % Tracers
%                 for j=1:handles.Model(md).Input(ad).nrTracers
%                     handles.Model(md).Input(ad).openBoundaries(i).tracer(j).nrTimeSeries=2;
%                     handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
%                     
%                     handles.Model(md).Input(ad).openBoundaries(i).tracer(j).profile='uniform';
%                     handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesA=zersunif;
%                     handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesB=zersunif;
%                     
%                     if isfield(bnd(i),'tracer')
%                         if length(bnd(i).tracer)<=j
%                             handles.Model(md).Input(ad).openBoundaries(i).tracer(j).nrTimeSeries=length(bnd(i).tracer(j).timeSeriesT);
%                             handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesT=bnd(i).tracer(j).timeSeriesT;
%                             handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesA=bnd(i).tracer(j).timeSeriesA;
%                             handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesB=bnd(i).tracer(j).timeSeriesB;
%                             handles.Model(md).Input(ad).openBoundaries(i).tracer(j).profile=bnd(i).tracer(j).profile;
%                         end
%                     end
%                 end
%                 
%                 % Sediments
%                 for j=1:handles.Model(md).Input(ad).nrSediments
%                     
%                     handles.Model(md).Input(ad).openBoundaries(i).sediment(j).nrTimeSeries=2;
%                     handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
%                     
%                     handles.Model(md).Input(ad).openBoundaries(i).sediment(j).profile='uniform';
%                     handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesA=zersunif;
%                     handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesB=zersunif;
%                     
%                     if isfield(bnd(i),'sediment')
%                         if length(bnd(i).sediment)<=j
%                             handles.Model(md).Input(ad).openBoundaries(i).sediment(j).nrTimeSeries=length(bnd(i).sediment(j).timeSeriesT);
%                             handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesT=bnd(i).sediment(j).timeSeriesT;
%                             handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesA=bnd(i).sediment(j).timeSeriesA;
%                             handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesB=bnd(i).sediment(j).timeSeriesB;
%                             handles.Model(md).Input(ad).openBoundaries(i).sediment(j).profile=bnd(i).sediment(j).profile;
%                         end
%                     end
%                 end
%             end
%             
%         end
%         
%     end
    
    
%     if handles.toolbox.nesting.nestHydro
%         [filename, pathname, filterindex] = uiputfile('*.bct','Select Timeseries Conditions File');
%         if pathname~=0
%             curdir=[lower(cd) '\'];
%             if ~strcmpi(curdir,pathname)
%                 filename=[pathname filename];
%             end
%             handles.Model(md).Input(ad).bctFile=filename;
%             ddb_saveBctFile(handles,ad);
%         end
%     end
%     
%     
%     if handles.toolbox.nesting.nestTransport
%         [filename, pathname, filterindex] = uiputfile('*.bcc','Select Transport Conditions File');
%         if pathname~=0
%             curdir=[lower(cd) '\'];
%             if ~strcmpi(curdir,pathname)
%                 filename=[pathname filename];
%             end
%             handles.Model(md).Input(ad).bccFile=filename;
%             ddb_saveBccFile(handles,ad);
%         end
%     end
    
    
end

setHandles(handles);

