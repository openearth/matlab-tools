function ddb_findToolboxes
%DDB_FINDTOOLBOXES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_findToolboxes
%
%   Input:

%
%
%
%
%   Example
%   ddb_findToolboxes
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
    dr=[ctfroot filesep 'ddbsettings' filesep 'toolboxes'];
else
    ddb_root = fileparts(which('delftdashboard.ini'));
    dr=[ddb_root filesep 'toolboxes'];
end

handles.Toolbox(1).name='dummy';

if isdeployed
    
    % No difference between standard and additional toolboxes and toolboxes
    % are all enabled
    flist=dir(dr);
    k=0;
    for i=1:length(flist)
        if flist(i).isdir
            switch lower(flist(i).name)
                case{'.','..','.svn'}
                otherwise
                    k=k+1;
                    name{k}=flist(i).name;
                    tp{k}='standard';
            end
        end
    end
    
else
    
    % Find standard toolboxes
    flist=dir(dr);
    k=0;
    for i=1:length(flist)
        if flist(i).isdir
            switch lower(flist(i).name)
                case{'.','..','.svn'}
                otherwise
                    fname=[dr filesep flist(i).name filesep 'xml' filesep flist(i).name '.xml'];
                    if exist(fname,'file')
                        xml=xml2struct(fname,'structuretype','short');
                        switch lower(xml.enable)
                            case{'1','y','yes'}
                                k=k+1;
                                name{k}=flist(i).name;
                                tp{k}='standard';
                        end
                    end
            end
        end
    end
    
    % Find additional toolboxes
    dr2=handles.additionalToolboxDir;
    if ~isempty(dr2)
        addpath(genpath(dr2));
        flist=dir(dr2);
        for i=1:length(flist)
            if flist(i).isdir
                switch lower(flist(i).name)
                    case{'.','..','.svn'}
                    otherwise
                        fname=[dr2 filesep flist(i).name filesep 'xml' filesep flist(i).name '.xml'];
                        if exist(fname,'file')
                            xml=xml2struct(fname,'structuretype','short');
                            switch lower(xml.enable)
                                case{'1','y','yes'}
                                    k=k+1;
                                    name{k}=flist(i).name;
                                    tp{k}='additional';
                            end
                        end
                end
            end
        end
    end
    
end


% Set names and functions
nt=k;
for i=1:nt
    handles.Toolbox(i).name=name{i};
    handles.Toolbox(i).longName=name{i};
    handles.Toolbox(i).callFcn=str2func(['ddb_' name{i} 'Toolbox']);
    handles.Toolbox(i).iniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Toolbox(i).plotFcn=str2func(['ddb_plot' name{i}]);
    handles.Toolbox(i).coordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    if isdeployed
        % Executable
        handles.Toolbox(i).dir=[dr filesep name{i} filesep];
        handles.Toolbox(i).xmlDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'xml' filesep];
%         handles.Toolbox(i).miscDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'misc' filesep];
        handles.Toolbox(i).dataDir=[handles.toolBoxDir name{i} filesep];
    else
        % From Matlab
        if strcmpi(tp{i},'standard')
            handles.Toolbox(i).dir=[dr filesep name{i} filesep];
            handles.Toolbox(i).xmlDir=[handles.Toolbox(i).dir 'xml' filesep];
%             handles.Toolbox(i).miscDir=[handles.Toolbox(i).dir 'misc' filesep];
            handles.Toolbox(i).dataDir=[handles.toolBoxDir name{i} filesep];
        else
            handles.Toolbox(i).dir=[dr2 filesep name{i} filesep];
            handles.Toolbox(i).xmlDir=[handles.Toolbox(i).dir 'xml' filesep];
%             handles.Toolbox(i).miscDir=[handles.Toolbox(i).dir 'misc' filesep];
%             handles.Toolbox(i).dataDir=[handles.Toolbox(i).dir 'data' filesep];
            handles.Toolbox(i).dataDir=[handles.toolBoxDir name{i} filesep];
        end
    end
end

% Set ModelMaker to be the first toolbox
ii=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');
tt=handles.Toolbox;
handles.Toolbox(1)=tt(ii);
k=1;
for i=1:length(handles.Toolbox)
    if ~strcmpi(tt(i).name,'ModelMaker')
        k=k+1;
        handles.Toolbox(k)=tt(i);
    end
end

% % Run very first initialize function
% for i=1:nt
%     f=handles.Toolbox(i).iniFcn;
%     handles=f(handles,'veryfirst');
% end

% Read xml files
for i=1:nt
    handles=ddb_readToolboxXML(handles,i);
end

handles.activeToolbox.name='ModelMaker';
handles.activeToolbox.nr=1;

setHandles(handles);

