function ddb_findModels
%DDB_FINDMODELS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_findModels
%
%   Input:

%
%
%
%
%   Example
%   ddb_findModels
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

if isdeployed
    dr=[ctfroot filesep 'models'];
else
    ddb_root = fileparts(which('delftdashboard.ini'));
    dr=[ddb_root filesep 'models'];
end

flist=dir(dr);
k=0;
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                if isdeployed
                    % xml file in settings dir
                    xmlfile=[handles.settingsDir filesep 'models' filesep flist(i).name filesep 'xml' filesep flist(i).name '.xml'];
                else
                    % xml file in model code dir
                    xmlfile=[dr filesep flist(i).name filesep 'xml' filesep flist(i).name '.xml'];
                end
                if exist(xmlfile,'file')
                    xml=fastxml2struct(xmlfile,'structuretype','short');
                    switch lower(xml.enable)
                        case{'1','y','yes'}
                            k=k+1;
                            name{k}=flist(i).name;
                    end
                end
        end
    end
end

nt=k;

for i=1:nt
    handles.Model(i).dir=[dr filesep name{i} filesep];
    handles.Model(i).name=name{i};
    handles.Model(i).longName=name{i};
    handles.Model(i).iniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Model(i).plotFcn=str2func(['ddb_plot' name{i}]);
    handles.Model(i).saveFcn=str2func(['ddb_save' name{i}]);
    handles.Model(i).openFcn=str2func(['ddb_open' name{i}]);
    handles.Model(i).clrFcn=str2func(['ddb_clear' name{i}]);
    handles.Model(i).coordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    handles.Model(i).GUI=[];
    if isdeployed
        handles.Model(i).xmlDir=[handles.settingsDir filesep 'models' filesep name{i} filesep 'xml' filesep];
    else
        handles.Model(i).xmlDir=[dr filesep name{i} filesep 'xml' filesep];
    end
end

% Set Delft3D-FLOW
ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');
tt=handles.Model;
handles.Model(1)=tt(ii);
k=1;
for i=1:length(handles.Model)
    if ~strcmpi(tt(i).name,'Delft3DFLOW')
        k=k+1;
        handles.Model(k)=tt(i);
    end
end

% Read xml files
for i=1:nt
    handles=ddb_readModelXML(handles,i);
end

handles.activeModel.name='Delft3DFLOW';
handles.activeModel.nr=1;

setHandles(handles);

