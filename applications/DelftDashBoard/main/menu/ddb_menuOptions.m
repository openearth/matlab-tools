function ddb_menuOptions(hObject, eventdata, handles)
%DDB_MENUOPTIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuOptions(hObject, eventdata, handles)
%
%   Input:
%   hObject   =
%   eventdata =
%   handles   =
%
%
%
%
%   Example
%   ddb_menuOptions
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

tg=get(hObject,'Tag');

switch tg,
    case{'menuOptionsCoordinateConversion'}
        ddb_menuOptionsCoordinateConversion_Callback(hObject,eventdata,handles);
    case{'menuOptionsMuppet'}
        ddb_menuOptionsMuppet_Callback(hObject,eventdata,handles);
    case{'menuOptionsQuickplot'}
        ddb_menuOptionsQuickplot_Callback(hObject,eventdata,handles);
    case{'menuOptionsLdbTool'}
        ddb_menuOptionsLdbTool_Callback(hObject,eventdata,handles);
    case{'menuOptionsDatamanagementbathymetry','menuOptionsDatamanagementshorelines','menuOptionsDatamanagementtidemodels'}
        ddb_menuOptionsDM_Callback(hObject,eventdata,handles);    
end

%%
function ddb_menuOptionsCoordinateConversion_Callback(hObject, eventdata, handles)
SuperTrans(handles.EPSG);
guidata(hObject, handles);

%%
function ddb_menuOptionsMuppet_Callback(hObject, eventdata, handles)
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\muppet\bin\muppet.exe']);

%%
function ddb_menuOptionsLdbTool_Callback(hObject, eventdata, handles)

%LdbTool;
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\ldbtool\bin\ldbtool.exe']);

%%
function ddb_menuOptionsQuickplot_Callback(hObject, eventdata, handles)
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\quickplot\bin\win32\d3d_qp.exe']);

%%
function ddb_menuOptionsDM_Callback(hObject,eventdata,handles)

switch get(hObject,'Tag');
    case 'menuOptionsDatamanagementbathymetry'
        urls = {handles.Bathymetry.Dataset(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Bathymetry',{handles.Bathymetry.Dataset(:).longName},{handles.Bathymetry.Dataset(:).Name},fileLoc);
        
    case 'menuOptionsDatamanagementshorelines'
        urls = {handles.Shorelines.Shoreline(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Shorelines',{handles.Shorelines.Shoreline(:).longName},{handles.Shorelines.Shoreline(:).Name},fileLoc);

    case 'menuOptionsDatamanagementtidemodels'
        urls = {handles.TideModels.Model(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Tidemodels',{handles.TideModels.Model(:).longName},{handles.TideModels.Model(:).Name},fileLoc);

end