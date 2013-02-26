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

    % Read xml file
    dr=[handles.toolBoxDir 'navigationcharts' filesep'];
    
    xml=fastxml2struct([dr 'NavigationCharts.xml'],'structuretype','short');

    n=0;
    for jj=1:length(xml.file)
        if exist([dr xml.file(jj).file.name],'file')
            n=n+1;
            s=load([dr xml.file(jj).file.name]);
            handles.Toolbox(ii).Input.charts(n).name=s.name;
            handles.Toolbox(ii).Input.charts(n).longname=s.longname;
            handles.Toolbox(ii).Input.charts(n).box=s.Box;
            handles.Toolbox(ii).Input.charts(n).url=fileparts(xml.file(jj).file.URL);
            handles.Toolbox(ii).Input.databases{n}=s.longname;            
        end
    end

end

handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeChart=1;
handles.Toolbox(ii).Input.showShoreline=1;
handles.Toolbox(ii).Input.showSoundings=1;
handles.Toolbox(ii).Input.showContours=1;
handles.Toolbox(ii).Input.activeChartName='';
handles.Toolbox(ii).Input.oldChartName='';
handles.Toolbox(tb).Input.selectedChart=1;

if ~isfield(handles.Toolbox(ii).Input,'databases')
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
elseif isempty(handles.Toolbox(ii).Input.databases)
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
end

