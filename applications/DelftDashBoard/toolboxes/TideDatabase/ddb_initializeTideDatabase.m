function handles = ddb_initializeTideDatabase(handles, varargin)
%DDB_INITIALIZETIDEDATABASE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTideDatabase(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTideDatabase
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
ii=strmatch('TideDatabase',{handles.Toolbox(:).name},'exact');

handles.Toolbox(ii).Input.activeModel=1;
handles.Toolbox(ii).Input.xLim(1)=0;
handles.Toolbox(ii).Input.yLim(1)=0;
handles.Toolbox(ii).Input.xLim(2)=0;
handles.Toolbox(ii).Input.yLim(2)=0;

handles.Toolbox(ii).Input.exportFormats={'tek','mat'};
handles.Toolbox(ii).Input.exportFormatExtensions={'*.tek','*.mat'};
handles.Toolbox(ii).Input.exportFormatNames={'Tekal file','Mat file'};

handles.Toolbox(ii).Input.activeExportFormatIndex=1;
handles.Toolbox(ii).Input.activeExportFormat=handles.Toolbox(ii).Input.exportFormats{1};
handles.Toolbox(ii).Input.activeExportFormatExtension=handles.Toolbox(ii).Input.exportFormatExtensions{1};

handles.Toolbox(ii).Input.tideDatabaseBoxHandle=[];
handles.Toolbox(ii).Input.fourierFile='';
handles.Toolbox(ii).Input.fourierOutFile='';
handles.Toolbox(ii).Input.exportFile='';

