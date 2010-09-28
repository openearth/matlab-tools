function handles = ddb_dmSelector(handles,figTitle,data,names,locs)
%DDB_DMSELECTOR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_dmSelector(handles,title,data,names,locs)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   handles = ddb_dmSelector(handles,'Bathymetry',{'set1','set2'},{'set1.nc','set2.nc'},{'opendap','local'});
%
%   See also DelftDashboard

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Arjan Mol
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
dmFig = makeNewWindow(figTitle,[600 400],[handles.SettingsDir '\icons\deltares.gif']);

% static items
dataTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmDataTxt','String','Data set',...
    'FontWeight','bold','Position',[0.01 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
nameTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmNameTxt','String','File name',...
    'FontWeight','bold','Position',[0.41 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
odTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmOdTxt','String','OpenDap',...
    'FontWeight','bold','Position',[0.61 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
locTxt = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag','ddb_dmLocTxt','String','Local',...
    'FontWeight','bold','Position',[0.81 0.9 0.2 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));

applyBut = uicontrol('Parent',dmFig','Units','normalized','Style','pushbutton','String','Apply','position',[0.6 0.05 0.18 0.05],'Callback',{@dmApply});
cancelBut = uicontrol('Parent',dmFig','Units','normalized','Style','pushbutton','String','Cancel','position',[0.8 0.05 0.18 0.05],'Callback',{@dmCancel});

% dynamic items
vertPos = [0.2:0.6/(length(data)-1):0.8];

for ii = 1:length(data)
    hData(ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag',['ddb_dmData_' num2str(ii)],'String',data{ii},...
        'FontWeight','normal','Position',[0.01 vertPos(ii) 0.39 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
    hName(ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','text','Tag',['ddb_dmName_' num2str(ii)],'String',names{ii},...
        'FontWeight','normal','Position',[0.41 vertPos(ii) 0.39 0.05],'horizontalAlignment','left','BackgroundColor',get(dmFig,'color'));
    hRB(1,ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','radiobutton','Tag',['ddb_dmOd_' num2str(ii)],...
        'Value',strcmp(locs{ii},'opendap'),'Position',[0.61 vertPos(ii) 0.05 0.05],'BackgroundColor',get(dmFig,'color'),'Callback',{@dmRadioBut});
    hRB(2,ii) = uicontrol('Parent',dmFig,'Units','normalized','Style','radiobutton','Tag',['ddb_dmLoc_' num2str(ii)],...
        'Value',strcmp(locs{ii},'local'),'Position',[0.81 vertPos(ii) 0.05 0.05],'BackgroundColor',get(dmFig,'color'),'Callback',{@dmRadioBut});
end

%%
function dmApply(hObject,eventdata)
handles=getHandles;
dmFig = get(hObject,'Parent');
datatype = lower(get(dmFig,'Tag'));
dataDir = handles.BathyDir(1:findstr(handles.BathyDir,'bathymetry')-1);
ddb_opendap_fileS = 'http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/';
ddb_opendap_dodsC = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/delftdashboard/';

switch datatype
    case 'bathymetry'
        for ii = 1:length(handles.Bathymetry.NrDatasets)
            fname  = handles.Bathymetry.Dataset(ii).Name;
            locURL = [dataDir 'bathymetry' filesep fname filesep]; % url if file is stored locally
            odURL  = [ddb_opendap_fileS 'bathymetry/' fname '/']; % url for file on opendap server
            
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') && isempty(strfind(handles.Bathymetry.Dataset(ii).URL,'opendap'))
                % then data is now local and is requested to use data on opendap
                
                % ask if local data file must be deleted
                ans=questdlg(['Do you want to delete the local file ' locURL filesep fname '.nc ?'],'Question','Yes','No','Yes');
                if strcmp(ans,'Yes')
                    delete([locURL filesep fname '.nc']);
                end
                %(TODO: delete tiles!)
                
                % change URL in def-file and in handles structure
                strfrep([handles.BathyDir '\tiledbathymetries.def'],locURL,odURL);
                handles.Bathymetry.Dataset(ii).URL = odURL;
                
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') && isempty(strfind(handles.Bathymetry.Dataset(ii).URL,'local'))
                % then data is now on opendap and it is required to use local data (check if it exists on local drive, otherwise make a copy)
                
                % copy file to local data dir
                if ~exist(locURL,'dir')
                    mkdir(locURL);
                end
                urlwrite([odURL '/' fname '.nc'],[locURL filesep fname '.nc']);
                %(TODO: copy tiles!)
                
                % change URL in def-file and in handles structure
                strfrep([handles.BathyDir '\tiledbathymetries.def'],odURL,locURL);
                handles.Bathymetry.Dataset(ii).URL = locURL;
            end
        end
    case 'tidemodels'
        for ii = 1:length(handles.TideModels.nrModels)
            fname  = handles.TideModels.Model(ii).Name;
            locURL = [dataDir 'tidemodels' filesep]; % url if file is stored locally
            odURL  = [ddb_opendap_dodsC 'tidemodels/']; % url for file on opendap server
            
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') && isempty(strfind(handles.TideModels.Model(ii).URL,'opendap'))
                % then data is now local and is requested to use data on opendap
                
                % ask if local data file must be deleted
                ans=questdlg(['Do you want to delete the local file ' locURL filesep fname '.nc ?'],'Question','Yes','No','Yes');
                if strcmp(ans,'Yes')
                    delete([locURL filesep fname '.nc']);
                end
                
                % change URL in def-file and in handles structure
                strfrep([handles.TideDir '\tiledbathymetries.def'],locURL,odURL);
                handles.TideModels.Model(ii).URL = odURL;
                
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') && isempty(strfind(handles.TideModels.Model(ii).URL,'local'))
                % then data is now on opendap and it is required to use local data (check if it exists on local drive, otherwise make a copy)
                
                % copy file to local data dir
                urlwrite([odURL '/' fname '.nc'],[locURL filesep fname '.nc']);
                
                % change URL in def-file and in handles structure
                strfrep([handles.TideDir '\tidemodels.def'],odURL,locURL);
                handles.TideModels.Model(ii).URL = locURL;
            end
        end        
    case 'shorelines'
        for ii = 1:length(handles.Shorelines.NrDatasets)
            fname  = handles.Shorelines.Dataset(ii).Name;
            locURL = [dataDir 'shorelines' filesep fname filesep]; % url if file is stored locally
            odURL  = [ddb_opendap_fileS 'shorelines/' fname '/']; % url for file on opendap server
            
            if get(findobj(dmFig,'tag',['ddb_dmOd_' num2str(ii)]),'Value') && isempty(strfind(handles.Shorelines.Dataset(ii).URL,'opendap'))
                % then data is now local and is requested to use data on opendap
                
                % ask if local data file must be deleted
                ans=questdlg(['Do you want to delete the local file ' locURL filesep fname '.nc ?'],'Question','Yes','No','Yes');
                if strcmp(ans,'Yes')
                    delete([locURL filesep fname '.nc']);
                end
                %(TODO: delete tiles!)
                
                % change URL in def-file and in handles structure
                strfrep([handles.ShorelineDir '\shorelines.def'],locURL,odURL);
                handles.Shorelines.Dataset(ii).URL = odURL;
                
            elseif get(findobj(dmFig,'tag',['ddb_dmLoc_' num2str(ii)]),'Value') && isempty(strfind(handles.Shorelines.Dataset(ii).URL,'local'))
                % then data is now on opendap and it is required to use local data (check if it exists on local drive, otherwise make a copy)
                
                % copy file to local data dir
                % copy file to local data dir
                if ~exist(locURL,'dir')
                    mkdir(locURL);
                end
                urlwrite([odURL '/' fname '.nc'],[locURL filesep fname '.nc']);
                %(TODO: copy tiles!)
                
                % change URL in def-file and in handles structure
                strfrep([handles.ShorelineDir '\shorelines.def'],odURL,locURL);
                handles.Shorelines.Dataset(ii).URL = locURL;
            end
        end
end

setHandles(handles);
close(dmFig);
%%
function dmCancel(hObject,eventdata)
close(get(hObject,'Parent'));
%%
function dmRadioBut(hObject,eventdata)
set(hObject,'Value',1);
if ~isempty(findstr(get(hObject,'tag'),'Loc'))
    set(findobj(get(hObject,'Parent'),'tag',strrep(get(hObject,'tag'),'Loc','Od')),'Value',0);
elseif ~isempty(findstr(get(hObject,'tag'),'Od'))
    set(findobj(get(hObject,'Parent'),'tag',strrep(get(hObject,'tag'),'Od','Loc')),'Value',0);
end
