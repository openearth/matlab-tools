function handles = ddb_initializeNavigationCharts(handles, varargin)
%DDB_INITIALIZENAVIGATIONCHARTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNavigationCharts(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNavigationCharts
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
ii=strmatch('NavigationCharts',{handles.Toolbox(:).name},'exact');

ddb_getToolboxData(handles.Toolbox(ii).dataDir,ii);

handles.Toolbox(ii).Input.longName='Navigation Charts';
handles.Toolbox(ii).Input.databases=[];
handles.Toolbox(ii).Input.charts=[];
if isdir([handles.toolBoxDir 'navigationcharts'])
    lst=dir([handles.toolBoxDir 'NavigationCharts']);
    k=0;
    for i=1:length(lst)
        if isdir([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name])
            switch(lst(i).name)
                case{'.','..'}
                otherwise
                    if exist([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name filesep lst(i).name '.mat'],'file')
                        k=k+1;
                        disp(['Loading navigation charts ' lst(i).name ' ...']);
                        s=load([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name filesep lst(i).name '.mat']);
                        handles.Toolbox(ii).Input.databases{k}=lst(i).name;
                        handles.Toolbox(ii).Input.charts(k).box=s.Box;
                    else
                        handles.Toolbox(ii).Input.databases=[];
                        disp([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name filesep lst(i).name '.mat not found!']);
                        handles.Toolbox(ii).Input.databases=[];
                    end
            end
        end
    end
end
handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeChart=1;
handles.Toolbox(ii).Input.showShoreline=1;
handles.Toolbox(ii).Input.showSoundings=1;
handles.Toolbox(ii).Input.showContours=1;
handles.Toolbox(ii).Input.activeChartName='';

if ~isfield(handles.Toolbox(ii).Input,'databases')
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
elseif isempty(handles.Toolbox(ii).Input.databases)
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
end

