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
ii=strmatch('TropicalCyclone',{handles.Toolbox(:).name},'exact');

ddb_getToolboxData(handles.Toolbox(ii).dataDir,ii);

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

if ~isdir(handles.Toolbox(ii).dataDir)
    mkdir(handles.Toolbox(ii).dataDir);
end

handles.Toolbox(ii).Input.nrTrackPoints   = 0;
handles.Toolbox(ii).Input.name      = '';
handles.Toolbox(ii).Input.initSpeed = 0;
handles.Toolbox(ii).Input.initDir   = 0;
handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.timeStep=6;

handles.Toolbox(ii).Input.quadrantOption='uniform';
handles.Toolbox(ii).Input.quadrant=1;

handles.Toolbox(ii).Input.vMax=120;
handles.Toolbox(ii).Input.rMax=20;
handles.Toolbox(ii).Input.pDrop=5000;
handles.Toolbox(ii).Input.parA=1;
handles.Toolbox(ii).Input.parB=1;
handles.Toolbox(ii).Input.r100=0;
handles.Toolbox(ii).Input.r65=0;
handles.Toolbox(ii).Input.r50=0;
handles.Toolbox(ii).Input.r35=0;

% Track
handles.Toolbox(ii).Input.trackT=floor(now);
handles.Toolbox(ii).Input.trackX=0;
handles.Toolbox(ii).Input.trackY=0;
handles.Toolbox(ii).Input.trackVMax=0;
handles.Toolbox(ii).Input.trackPDrop=0;
handles.Toolbox(ii).Input.trackRMax=0;
handles.Toolbox(ii).Input.trackR100=0;
handles.Toolbox(ii).Input.trackR65=0;
handles.Toolbox(ii).Input.trackR50=0;
handles.Toolbox(ii).Input.trackR35=0;
handles.Toolbox(ii).Input.trackA=0;
handles.Toolbox(ii).Input.trackB=0;

% Table
handles.Toolbox(ii).Input.tableVMax=0;
handles.Toolbox(ii).Input.tablePDrop=0;
handles.Toolbox(ii).Input.tableRMax=0;
handles.Toolbox(ii).Input.tableR100=0;
handles.Toolbox(ii).Input.tableR65=0;
handles.Toolbox(ii).Input.tableR50=0;
handles.Toolbox(ii).Input.tableR35=0;
handles.Toolbox(ii).Input.tableA=0;
handles.Toolbox(ii).Input.tableB=0;

handles.Toolbox(ii).Input.showDetails=1;
handles.Toolbox(ii).Input.name='TC Deepak';
handles.Toolbox(ii).Input.radius=1000;
handles.Toolbox(ii).Input.nrRadialBins=500;
handles.Toolbox(ii).Input.nrDirectionalBins=36;
handles.Toolbox(ii).Input.method=4;

handles.Toolbox(ii).Input.deleteTemporaryFiles=1;

handles.Toolbox(ii).Input.trackhandle=[];

%  Tropical cyclone (TC) widgets, parameters added by QNA/NRL:
handles.Toolbox(ii).Input.showTCBasins=0;
handles.Toolbox(ii).Input.whichTCBasinOption=0;     % Nearest (0 for nearest, 1 for All)
handles.Toolbox(ii).Input.oldwhichTCBasinOption=2;  % Nearest (init. to 2)
handles.Toolbox(ii).Input.TCBasinName='';
handles.Toolbox(ii).Input.TCBasinNameAbbrev='';
handles.Toolbox(ii).Input.TCBasinFileName='';
handles.Toolbox(ii).Input.oldTCBasinName='';
handles.Toolbox(ii).Input.TCStormName='';
handles.Toolbox(ii).Input.oldTCStormName='';
handles.Toolbox(ii).Input.TCTrackFile={'Current Track File'};
handles.Toolbox(ii).Input.TCTrackFileStormName='';
%  Lists of known TC basin names and abbreviations:
handles.Toolbox(ii).Input.knownTCBasinName = {'Atlantic','Central Pacific','East Pacific','Southern Hemisphere','West Pacific'};
handles.Toolbox(ii).Input.knownTCBasinNameAbbrev = {'at', 'cp', 'ep', 'sh', 'wp'};

%  Check whether the TCBasinHandles list exists & is empty (may not be if
%  File -> New was clicked).
if (isfield(handles.Toolbox(ii).Input, 'TCBasinHandles') && ~isempty(handles.Toolbox(ii).Input.TCBasinHandles))
    %  List is not empty, so delete any existing objects.
    for i = 1:length(handles.Toolbox(tb).Input.TCBasinHandles)
        %  Delete the current TC basin polygon handle.
        if (ishandle(handles.Toolbox(tb).Input.TCBasinHandles(i)))
            delete(handles.Toolbox(tb).Input.TCBasinHandles(i));
        end
    end
end
handles.Toolbox(ii).Input.TCBasinHandles=[];

%  Define the directory in which TC basin polygon files reside, then store a listing of the .xy files.
handles.Toolbox(ii).Input.tcBasinsDir = [fileparts(fileparts(handles.settingsDir)) filesep 'external' filesep 'data'];
handles.Toolbox(ii).Input.tcBasinsFiles = dir([handles.Toolbox(ii).Input.tcBasinsDir filesep '*.xy']);

handles.Toolbox(ii).Input.importFormat='JTWCCurrentTrack';
handles.Toolbox(ii).Input.importFormats={'JTWCCurrentTrack','NHCCurrentTrack','JTWCBestTrack','UnisysBestTrack','jmv30'};
handles.Toolbox(ii).Input.importFormatNames={'JTWC Current Track...','NHC Current Track...','JTWC Best Track','Unisys Best Track','JMV 3.0'};

handles.Toolbox(ii).Input.downloadLocation='JTWCCurrentTracks';
handles.Toolbox(ii).Input.downloadLocations={'JTWCCurrentTracks','NHCCurrentTracks','UnisysBestTracks','JTWCBestTracks','JTWCCurrentCyclones'};
handles.Toolbox(ii).Input.downloadLocationNames={'JTWC Current Cyclones...','NHC Current Hurricanes...','UNISYS Track Archive','JTWC Track Archive','JTWC Current Cyclones (Web)'};


