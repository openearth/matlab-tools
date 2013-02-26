function handles = ddb_initializeTideStations(handles, varargin)
%DDB_INITIALIZETIDESTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTideStations(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTideStations
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

%% When enabled on OpenDAP
% % Check xml-file for updates
% ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');
% dr=handles.Toolbox(ii).dataDir;
% flist = dir([dr '*.xml']);
% xmlfile = flist(1).name;
% url = ['http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/toolboxes/TideStations/' xmlfile];
% handles.Toolbox(ii).Input = ddb_getXmlData(dr,url,xmlfile);
% 
% % Update nc-files when necessary
% fld = fieldnames(handles.Toolbox(ii).Input);
% for ii=1:length(handles.Toolbox(ii).Input.(fld{1}))
%     if handles.Toolbox(ii).Input.(fld{1})(ii).update == 1
%         cstr = strsplit(handles.Toolbox(ii).Input.(fld{1})(ii).URL,'/');
%         urlwrite(handles.Toolbox(ii).Input.(fld{1})(ii).URL,[dr cstr{end}]);
%     end
% end
% 
% % Remaining code remains the same from flist = dir([dr '*.nc'])

%% For the time being...
ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');

ddb_getToolboxData(handles.Toolbox(ii).dataDir,ii);

dr=handles.Toolbox(ii).dataDir;
lst=dir([dr '*.nc']);

handles.Toolbox(ii).Input.databases={''};

if isempty(lst)
    error('No databases for tide stations found!');
end

for i=1:length(lst)

    disp(['Loading tide database ' lst(i).name(1:end-3) ' ...']);
    fname=[dr lst(i).name(1:end-3) '.nc'];
    handles.Toolbox(ii).Input.database(i).longName=nc_attget(fname,nc_global,'title');
    handles.Toolbox(ii).Input.databases{i}=handles.Toolbox(ii).Input.database(i).longName;
    handles.Toolbox(ii).Input.database(i).shortName=lst(i).name(1:end-3);
    handles.Toolbox(ii).Input.database(i).x=nc_varget(fname,'lon');
    handles.Toolbox(ii).Input.database(i).y=nc_varget(fname,'lat');
    handles.Toolbox(ii).Input.database(i).xLoc=handles.Toolbox(ii).Input.database(i).x;
    handles.Toolbox(ii).Input.database(i).yLoc=handles.Toolbox(ii).Input.database(i).y;
    
    handles.Toolbox(ii).Input.database(i).coordinateSystem='WGS 84';
    handles.Toolbox(ii).Input.database(i).coordinateSystemType='geographic';
    
    str=nc_varget(fname,'components');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).components{j}=deblank(str(j,:));
    end
    
    str=nc_varget(fname,'stations');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).stationList{j}=deblank(str(j,:));
        % Short names
        name=deblank(str(j,:));
        name=strrep(name,' ','');
        name=strrep(name,'#','');
        name=strrep(name,'\','');
        name=strrep(name,'/','');
        name=strrep(name,'.','');
        name=strrep(name,',','');
        name=strrep(name,'(','');
        name=strrep(name,')','');
        name=name(double(name)<1000);
        handles.Toolbox(ii).Input.database(i).stationShortNames{j}=name;
    end
    
    str=nc_varget(fname,'idcodes');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).idCodes{j}=deblank(str(j,:));
    end
    
    
end

handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.stopTime=floor(now)+30;
handles.Toolbox(ii).Input.timeStep=30.0;
handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeTideStation=1;
handles.Toolbox(ii).Input.tideStationHandle=[];
handles.Toolbox(ii).Input.activeTideStationHandle=[];

handles.Toolbox(ii).Input.components={''};
handles.Toolbox(ii).Input.amplitudes=0;
handles.Toolbox(ii).Input.phases=0;
handles.Toolbox(ii).Input.timeZone=0;
handles.Toolbox(ii).Input.verticalOffset=0;

handles.Toolbox(ii).Input.tidestationshandle=[];
