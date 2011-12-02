function handles = ddb_initializeOPeNDAPBrowser(handles, varargin)
%DDB_INITIALIZEOPENDAPBROWSER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeOPeNDAPBrowser(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeOPeNDAPBrowser
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
ii=strmatch('OPeNDAPBrowser',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'} % initialisation scripts
            handles.Toolbox(ii).longName='OPeNDAP Browser';
            
            %            lst=dir([handles.ToolBoxDir '\tidedatabase\*.mat']);
            %            for i=1:length(lst)
            %                disp(['Loading tide database ' lst(i).name(1:end-4) ' ...']);
            %                load([handles.ToolBoxDir 'tidedatabase\' lst(i).name(1:end-4) '.mat']);
            %                handles.Toolbox(ii).Databases{i}=s.DatabaseName;
            %                handles.Toolbox(ii).Database{i}=s;
            %                handles.Toolbox(ii).Database{i}.ShortName=lst(i).name(1:end-4);
            %                if size(handles.Toolbox(ii).Database{i}.x,1)==1
            %                    handles.Toolbox(ii).Database{i}.x=handles.Toolbox(ii).Database{i}.x';
            %                    handles.Toolbox(ii).Database{i}.y=handles.Toolbox(ii).Database{i}.y';
            %                end
            %            end
            
            return
    end
end

handles.Toolbox(ii).OPeNDAPServers={'http://opendap.deltares.nl/thredds/'};
%handles.Toolbox(ii).StopTime=floor(now)+30;
%handles.Toolbox(ii).TimeStep=10.0;

handles.Toolbox(ii).activeServer=1;

