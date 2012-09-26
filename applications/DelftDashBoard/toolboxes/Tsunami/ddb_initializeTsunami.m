function handles = ddb_initializeTsunami(handles, varargin)
%DDB_INITIALIZETSUNAMI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTsunami(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTsunami
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ii=strmatch('Tsunami',{handles.Toolbox(:).name},'exact');

ddb_getToolboxData(handles.Toolbox(ii).dataDir,ii);

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.nrSegments=0;

% handles.Toolbox(ii).Input.magnitude=0.0;
% handles.Toolbox(ii).Input.depthFromTop=0.0;
% handles.Toolbox(ii).Input.relatedToEpicentre=0;
% handles.Toolbox(ii).Input.latitude=0.0;
% handles.Toolbox(ii).Input.longitude=0.0;
% handles.Toolbox(ii).Input.totalFaultLength=0.0;
% handles.Toolbox(ii).Input.totalUserFaultLength=0.0;
% handles.Toolbox(ii).Input.faultWidth=0.0;
% handles.Toolbox(ii).Input.dislocation=0.0;
% handles.Toolbox(ii).Input.segment=0.0;
%
% handles.Toolbox(ii).Input.faultLength=0;
% handles.Toolbox(ii).Input.strike=0;
% handles.Toolbox(ii).Input.dip=0;
% handles.Toolbox(ii).Input.slipRake=0;
% handles.Toolbox(ii).Input.focalDepth=0;


% Overall info
handles.Toolbox(ii).Input.relatedToEpicentre=0;
handles.Toolbox(ii).Input.updateTable=1;
handles.Toolbox(ii).Input.updateParameters=1;

handles.Toolbox(ii).Input.faulthandle=[];

% Earthquake info
handles.Toolbox(ii).Input.Mw=0.0;
handles.Toolbox(ii).Input.depth=20.0;
handles.Toolbox(ii).Input.length=0.0;
handles.Toolbox(ii).Input.theoreticalFaultLength=0.0;
handles.Toolbox(ii).Input.width=0.0;
handles.Toolbox(ii).Input.slip=0.0;
handles.Toolbox(ii).Input.strike=0.0;
handles.Toolbox(ii).Input.dip=10.0;
handles.Toolbox(ii).Input.slipRake=90.0;
handles.Toolbox(ii).Input.lonEpicentre=0.0;
handles.Toolbox(ii).Input.latEpicentre=0.0;

% Segment info (for table)
handles.Toolbox(ii).Input.segmentLon=0.0;
handles.Toolbox(ii).Input.segmentLat=0.0;
handles.Toolbox(ii).Input.segmentX=0.0;
handles.Toolbox(ii).Input.segmentY=0.0;
handles.Toolbox(ii).Input.segmentStrike=0;
handles.Toolbox(ii).Input.segmentDip=0;
handles.Toolbox(ii).Input.segmentSlipRake=0;
handles.Toolbox(ii).Input.segmentDepth=0;
handles.Toolbox(ii).Input.segmentWidth=0;
handles.Toolbox(ii).Input.segmentFocalDepth=0;
handles.Toolbox(ii).Input.segmentSlip=0.0;

% File
handles.Toolbox(ii).Input.gridFile='';
