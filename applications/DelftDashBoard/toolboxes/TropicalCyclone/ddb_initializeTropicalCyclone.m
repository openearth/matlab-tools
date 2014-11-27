function handles = ddb_initializeTropicalCyclone(handles, varargin)
%DDB_INITIALIZETROPICALCYCLONE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTropicalCyclone(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTropicalCyclone
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

ddb_getToolboxData(handles.toolbox.tropicalcyclone.dataDir,'tropicalcyclone','TropicalCyclone');

if ~isdir(handles.toolbox.tropicalcyclone.dataDir)
    mkdir(handles.toolbox.tropicalcyclone.dataDir);
end

handles.toolbox.tropicalcyclone.nrTrackPoints   = 0;
handles.toolbox.tropicalcyclone.initSpeed = 0;
handles.toolbox.tropicalcyclone.initDir   = 0;
handles.toolbox.tropicalcyclone.startTime=floor(now);
handles.toolbox.tropicalcyclone.timeStep=6;

handles.toolbox.tropicalcyclone.quadrantOption='uniform';
handles.toolbox.tropicalcyclone.quadrant=1;

handles.toolbox.tropicalcyclone.vMax=120;
handles.toolbox.tropicalcyclone.rMax=20;
handles.toolbox.tropicalcyclone.pDrop=8000;
handles.toolbox.tropicalcyclone.parA=1;
handles.toolbox.tropicalcyclone.parB=1;
handles.toolbox.tropicalcyclone.r100=0;
handles.toolbox.tropicalcyclone.r65=0;
handles.toolbox.tropicalcyclone.r50=0;
handles.toolbox.tropicalcyclone.r35=0;

% Track
handles.toolbox.tropicalcyclone.trackT=floor(now);
handles.toolbox.tropicalcyclone.trackX=0;
handles.toolbox.tropicalcyclone.trackY=0;
handles.toolbox.tropicalcyclone.trackVMax=0;
handles.toolbox.tropicalcyclone.trackPDrop=0;
handles.toolbox.tropicalcyclone.trackRMax=0;
handles.toolbox.tropicalcyclone.trackR100=0;
handles.toolbox.tropicalcyclone.trackR65=0;
handles.toolbox.tropicalcyclone.trackR50=0;
handles.toolbox.tropicalcyclone.trackR35=0;
handles.toolbox.tropicalcyclone.trackA=0;
handles.toolbox.tropicalcyclone.trackB=0;

% Table
handles.toolbox.tropicalcyclone.tableVMax=0;
handles.toolbox.tropicalcyclone.tablePDrop=0;
handles.toolbox.tropicalcyclone.tableRMax=0;
handles.toolbox.tropicalcyclone.tableR100=0;
handles.toolbox.tropicalcyclone.tableR65=0;
handles.toolbox.tropicalcyclone.tableR50=0;
handles.toolbox.tropicalcyclone.tableR35=0;
handles.toolbox.tropicalcyclone.tableA=0;
handles.toolbox.tropicalcyclone.tableB=0;

handles.toolbox.tropicalcyclone.showDetails=1;
handles.toolbox.tropicalcyclone.cyclonename='TC Deepak';
handles.toolbox.tropicalcyclone.radius=1000;
handles.toolbox.tropicalcyclone.nrRadialBins=500;
handles.toolbox.tropicalcyclone.nrDirectionalBins=36;
handles.toolbox.tropicalcyclone.method=4;
handles.toolbox.tropicalcyclone.windconversionfactor=1.0;

handles.toolbox.tropicalcyclone.deleteTemporaryFiles=1;

handles.toolbox.tropicalcyclone.trackhandle=[];

%  Tropical cyclone (TC) widgets, parameters added by QNA/NRL:
handles.toolbox.tropicalcyclone.showTCBasins=0;
handles.toolbox.tropicalcyclone.whichTCBasinOption=0;     % Nearest (0 for nearest, 1 for All)
handles.toolbox.tropicalcyclone.oldwhichTCBasinOption=2;  % Nearest (init. to 2)
handles.toolbox.tropicalcyclone.TCBasinName='';
handles.toolbox.tropicalcyclone.TCBasinNameAbbrev='';
handles.toolbox.tropicalcyclone.TCBasinFileName='';
handles.toolbox.tropicalcyclone.oldTCBasinName='';
handles.toolbox.tropicalcyclone.TCStormName='';
handles.toolbox.tropicalcyclone.oldTCStormName='';
handles.toolbox.tropicalcyclone.TCTrackFile='';
handles.toolbox.tropicalcyclone.TCTrackFileStormName='';
%  Lists of known TC basin names and abbreviations:
handles.toolbox.tropicalcyclone.knownTCBasinName = {'Atlantic','Central Pacific','East Pacific','Indian Ocean','Southern Hemisphere','West Pacific'};
handles.toolbox.tropicalcyclone.knownTCBasinNameAbbrev = {'at', 'cp', 'ep', 'io', 'sh', 'wp'};

%  Check whether the TCBasinHandles list exists & is empty (may not be if
%  File -> New was clicked).
if (isfield(handles.toolbox.tropicalcyclone, 'TCBasinHandles') && ~isempty(handles.toolbox.tropicalcyclone.TCBasinHandles))
    %  List is not empty, so delete any existing objects.
    for i = 1:length(handles.toolbox.tropicalcyclone.TCBasinHandles)
        %  Delete the current TC basin polygon handle.
        if (ishandle(handles.toolbox.tropicalcyclone.TCBasinHandles(i)))
            delete(handles.toolbox.tropicalcyclone.TCBasinHandles(i));
        end
    end
end
handles.toolbox.tropicalcyclone.TCBasinHandles=[];

%  Define the directory in which TC basin polygon files reside, then store a listing of the .xy files.
handles.toolbox.tropicalcyclone.tcBasinsDir = [fileparts(fileparts(handles.settingsDir)) filesep 'external' filesep 'data'];
handles.toolbox.tropicalcyclone.tcBasinsFiles = dir([handles.toolbox.tropicalcyclone.tcBasinsDir filesep '*.xy']);

handles.toolbox.tropicalcyclone.importFormat='JTWCCurrentTrack';
handles.toolbox.tropicalcyclone.importFormats={'JTWCCurrentTrack','NHCCurrentTrack','JTWCBestTrack','UnisysBestTrack','jmv30'};
handles.toolbox.tropicalcyclone.importFormatNames={'JTWC Current Track...','NHC Current Track...','JTWC Best Track','Unisys Best Track','JMV 3.0'};

handles.toolbox.tropicalcyclone.downloadLocation='JTWCCurrentTracks';
handles.toolbox.tropicalcyclone.downloadLocations={'JTWCCurrentTracks','NHCCurrentTracks','UnisysBestTracks','JTWCBestTracks','JTWCCurrentCyclones'};
handles.toolbox.tropicalcyclone.downloadLocationNames={'JTWC Current Cyclones...','NHC Current Hurricanes...','UNISYS Track Archive','JTWC Track Archive','JTWC Current Cyclones (Web)'};


