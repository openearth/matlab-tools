function UCIT_DC_findAvailableActions(type)
%UCIT_DC_FINDAVAILABLEACTIONS   finds available actions given selected datatype
%
% This routine finds the routines to be added to the action popup. For this purpose
% the routine looks in three different locations: common actions from the demo version, 
% common actions from the developers directory and datatype specific actions 
%
% syntax:       
%    UCIT_DC_findAvailableActions(type)
%
% input:
%    type = variable identifying which kind of data is selected
%        1: transects
%        2: grids
%        3: lines
%        4: points
%
% output:
%    function has no output
%
% see also UCIT_DC_loadRelevantInfo2Popup
%

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date$ (Version 1.0, January 2006)
%     M.van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
switch  type
    case 1
        objTag='TrActions';
        datatype =  {'Jarkus Data' , 'Lidar Data US'};
        DataRootCommon0 = [fileparts(which('ucit_commonactions0.dir'))  filesep 'DataTransects' filesep];
        DataRootCommon1 = [fileparts(which('ucit_commonactions1.dir'))  filesep 'DataTransects' filesep];
        DataRootActions = [fileparts(which('ucit_actions.dir')) filesep 'DataTransects' filesep UCIT_getInfoFromPopup('TransectsDatatype') filesep];
    case 2
        objTag='GrActions';
        datatype = {'Jarkus' 'Vaklodingen'};
        DataRootCommon0 = [fileparts(which('ucit_commonactions0.dir'))  filesep 'DataGrids' filesep];
        DataRootCommon1 = [fileparts(which('ucit_commonactions1.dir'))  filesep 'DataGrids' filesep];
        DataRootActions = [fileparts(which('ucit_actions.dir')) filesep 'DataGrids' filesep UCIT_getInfoFromPopup('GridsDatatype') filesep];
    case 3
        objTag='LnActions';
        datatype = DBgetUniqueFields('line','datatype',{'datatypeinfo',UCIT_getInfoFromPopup('LinesDatatype')});
        DataRootCommon0 = [fileparts(which('ucit_commonactions0.dir'))  filesep 'DataLines' filesep];
        DataRootCommon1 = [fileparts(which('ucit_commonactions1.dir'))  filesep 'DataLines' filesep];
        DataRootActions = [fileparts(which('ucit_actions.dir')) filesep 'DataLines' filesep 'DataType' num2str(datatype{1}) filesep 'code' filesep 'actions' filesep];
    case 4
        objTag='PtActions';
        datatype = DBgetUniqueFields('point','datatype',{'datatypeinfo',UCIT_getInfoFromPopup('PointsDatatype')});
        DataRootCommon0 = [fileparts(which('ucit_commonactions0.dir'))  filesep 'DataPoints' filesep];
        DataRootCommon1 = [fileparts(which('ucit_commonactions1.dir'))  filesep 'DataPoints' filesep];
        DataRootActions = [fileparts(which('ucit_actions.dir')) filesep 'DataPoints' filesep 'DataType' num2str(datatype{1}) filesep 'code' filesep 'actions' filesep];
end

if isnumeric(datatype{1})
    if iscell(datatype)
        datatype=num2str(datatype{1});
    else
        datatype=num2str(datatype);
    end
else
    if iscell(datatype)
        datatype=datatype{1};
    else
        datatype=datatype;
    end
end

try
    % read common Delft3D Actions
    DataRootDelft3D=[fileparts(which('ucit_actions.dir')) filesep 'ModelActions' filesep];

    fns0 = dir([DataRootCommon0 '*.m']);
    fns1 = dir([DataRootCommon1 '*.m']);
    fns2 = dir([DataRootActions '*.m']);
    fns3 = dir([DataRootDelft3D '*.m']);
end

if size(fns0,1)==0 & size(fns2,1)==0
    string=[]; string{1}='No actions available ...';% find all area names ... then filter out unique ones
else
    clear action;
    path2add=[];
    % get available actions from the 'commonactions' directory in the demo
    if ~(size(fns0,1)==0)
        for i =1:size(fns0,1)
            [action{i}, rest]=strtok(fns0(i).name,'.');
            warning off
            path2add=[path2add DataRootCommon0 filesep char(action{i}) filesep ';'];
            warning on
        end
        temp=max(size(action));
    else
        temp=0;
    end
    
    % get available actions from the 'commonactions' directory in the developers directory
    if ~(size(fns1,1)==0)
        for i = 1 : size(fns1,1)
            [action{temp + i}, rest]=strtok(fns1(i).name,'.');
            warning off
            path2add=[path2add DataRootCommon1 filesep char(action{temp + i}) filesep ';'];
            warning on
        end
        temp=max(size(action));
    else
        temp=temp;
    end

    % get available actions from the 'DataType#\code\actions\' directory
    if ~(size(fns2,1)==0)
        for i = 1 : size(fns2,1)
            [action{temp+i}, rest]=strtok(fns2(i).name,'.');
            warning off
            path2add=[path2add DataRootActions datatype  filesep 'actions' filesep char(action{temp+i}) filesep ';'];
            warning on
        end
        temp=max(size(action));
    else
        temp=temp;
    end

    % get available model actions from the model actions directory
    for i =  1 : size(fns3,1)
        [action{temp+i}, rest]=strtok(fns3(i).name,'.');
        warning off
        path2add=[path2add DataRootDelft3D filesep char(action{temp+i}) filesep ';'];
        warning on
    end

    actions=unique(action);

    % manufacture the string for in the popup menu
    string=[]; string{1}='Select action ...';
    for i = 1:max(size(actions))
        string{i+1}=actions{i};
    end

    % add relevant paths to the Matlab path
    warning off
    path2add=[path2add DataRootCommon0 ';' path2add DataRootCommon1 ';' DataRootActions 'DataType' datatype filesep 'code' filesep ';' DataRootActions 'DataType' datatype filesep 'code' filesep 'actions' filesep ';'];
    addpath(path2add);
    warning on
end

set(findobj('tag',objTag), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');



