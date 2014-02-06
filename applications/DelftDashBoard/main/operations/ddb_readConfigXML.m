function ddb_readConfigXML(varargin)
%ddb_readConfigXML  Reads model versions, default coordinate system etc.

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

% $Id: ddb_setProxySettings.m 8254 2013-03-01 13:55:47Z ormondt $
% $Date: 2013-03-01 14:55:47 +0100 (Fri, 01 Mar 2013) $
% $Author: ormondt $
% $Revision: 8254 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_setProxySettings.m $
% $Keywords: $

%%
handles=getHandles;

xmldir=handles.xmlConfigDir;
xmlfile='delftdashboard.xml';
filename=[xmldir xmlfile];

% Set defaults
for imdl=1:length(handles.Model)

    handles.Model(imdl).versionlist = {'N/A'}; 
    handles.Model(imdl).version = 'N/A'; 
    handles.Model(imdl).exedir='d:\unknownfolder\';

    switch lower(handles.Model(imdl).name)
        case{'delft3dflow'}
            
            % Version list (used in GUI)
            handles.Model(imdl).versionlist = {'5.00.xx','6.00.xx','N/A'}; 

            % Set default
            handles.Model(imdl).version='6.00.xx';

            % Delft3D-FLOW
            if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin\d_hydro.exe'],'file')
                handles.Model(imdl).version='6.00.xx';
                handles.Model(imdl).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin\'];
            elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
                handles.Model(imdl).version='5.00.xx';
                handles.Model(imdl).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\'];       
            end

        case{'delft3dwave'}
            handles.Model(imdl).exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\'];
            
    end
end

if exist(filename,'file')
    % Read xml file
    xml=xml2struct(filename);
    % Set model versions
    for ii=1:length(xml.model)
        imdl=strmatch(lower(xml.model(ii).model.name),lower({handles.Model.name}),'exact');
        if ~isempty(imdl)
            handles.Model(imdl).version=xml.model(ii).model.version;
            if isempty(handles.Model(imdl).version)
                handles.Model(imdl).version='N/A';
            end                
            handles.Model(imdl).exedir=xml.model(ii).model.exedir;
            if isempty(handles.Model(imdl).exedir)
                handles.Model(imdl).version='d:\unknownfolder\';
            end                
        end
    end
else
    % Save xml file
    for ii=1:length(handles.Model)
        xml.model(ii).model.name=handles.Model(ii).name;
        xml.model(ii).model.version=handles.Model(ii).version;
        xml.model(ii).model.exedir=handles.Model(ii).exedir;
    end
    struct2xml(filename,xml,'structuretype','short');
end

setHandles(handles);
