function newdata = ddb_getXmlData(localdir,url,xmlfile)
%DDB_GETXMLDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_getXmlData(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_getXmlData
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       Wiebe.deBoer@deltares.nl
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
% Created: 05 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Check local xml-file else download from server
file = [localdir filesep xmlfile];
serverdata = [];
newdata=[];

if exist(file)==2
    data=xml_load(file);
    try
        ddb_urlwrite(url,[localdir filesep 'temp.xml']);
        serverdata = xml_load([localdir filesep 'temp.xml']);
        delete([localdir filesep 'temp.xml']); %cleanup
    catch
        % Data cannot be updated
        fld = fieldnames(data);
        for aa=1:length(data)
            data(aa).(fld{1}).update = 0;
        end
        warning(['Could not retrieve ''' xmlfile ''' from server, no data update!']);
    end 
else
    try
        if ~isdir(localdir)
           mkdir(localdir); 
        end
        ddb_urlwrite(url,file);
        data=xml_load(file);
        % All data needs to be updated
        fld = fieldnames(data);
        for aa=1:length(data)
            data(aa).(fld{1}).update = 1;
        end
    catch
        warning(['Could not retrieve ''' xmlfile ''' from server']);
        return
    end
end

%% If local data already existed and update could be retrieved from server, check which data is in need for update
if ~isempty(serverdata)
    
    fld = fieldnames(data);
    for aa=1:length(data)
        names{aa} = data(aa).(fld{1}).name;
        if isfield(data(aa).(fld{1}),'version')
            versions(aa) = str2double(data(aa).(fld{1}).version);
        else
            versions(aa)=0;
        end
        data(aa).(fld{1}).update = 0;
    end
    
    for bb=1:length(serverdata)
        % Check for new datasets on server
        if ~ismember(serverdata(bb).(fld{1}).name,names)
            llength = length(data);
            data(llength+1) = serverdata(bb);
            data(llength+1).(fld{1}).update = 1;
        else
            % Check for version updates on server
            [AA,id] = ismember(serverdata(bb).(fld{1}).name,names);
            if isfield(serverdata(bb).(fld{1}),'version')
                if versions(id) ~= str2double(serverdata(bb).(fld{1}).version);
                    Qupdate = questdlg(['There is an update for ' serverdata(bb).(fld{1}).name...
                        ', would you like to delete the old cache and update?'], ...
                        'Update?', ...
                        'Yes', 'No', 'Yes');
                    switch Qupdate,
                        case 'Yes',
                            data(id) = serverdata(bb);
                            data(id).(fld{1}).update = 1;
                            if isdir([localdir filesep serverdata(bb).(fld{1}).name])
                                rmdir([localdir filesep serverdata(bb).(fld{1}).name],'s');
                            end
                        case 'No',
                            data(id).(fld{1}).update = 0;
                    end
                end
            end
        end
    end
end

%% Convert data to DDB structure format (~= xml format)
for cc=1:length(data)
    fldnames=fieldnames(data(cc).(fld{1}));
    for ifld=1:length(fldnames)
        newdata.(fld{1})(cc).(fldnames{ifld}) = data(cc).(fld{1}).(fldnames{ifld});
    end
end

%% Update local xml-file (without update field)
for aa=1:length(data)
    xmldata(aa).(fld{1}) = rmfield(data(aa).(fld{1}),'update');
end
xml_save([localdir filesep xmlfile],xmldata,'off');
