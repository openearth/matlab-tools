function ddb_bathymetryCombineDatasets
%DDB_BATHYMETRYCOMBINEDATASETS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_bathymetryCombineDatasets
%
%   Input:

%
%
%
%
%   Example
%   ddb_bathymetryCombineDatasets
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ddb_refreshScreen('Toolbox','Combine Datasets');

handles=guidata(findobj('Tag','MainWindow'));

handles.ListDatasets = uicontrol(gcf,'Style','listbox','String','','Position',[60 65 160 95],'Tag','UIControl');
handles.TextHorizontalCoordinateSystem = uicontrol(gcf,'Style','text','String','',  'Position',[60 42 240 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextVerticalCoordinateSystem   = uicontrol(gcf,'Style','text','String','',  'Position',[60 25 240 15],'HorizontalAlignment','left','Tag','UIControl');

handles.PushAddDataset        = uicontrol(gcf,'Style','pushbutton','String','Add Dataset',      'Position',[230 140 100 20],'Tag','UIControl');
handles.PushUseDataset        = uicontrol(gcf,'Style','pushbutton','String','Use Dataset',      'Position',[230 115 100 20],'Tag','UIControl');
handles.PushRemoveDataset     = uicontrol(gcf,'Style','pushbutton','String','Remove Dataset',   'Position',[230  90 100 20],'Tag','UIControl');
handles.PushEditDetails       = uicontrol(gcf,'Style','pushbutton','String','Details',          'Position',[230  65 100 20],'Tag','UIControl');

handles.ListUsedDatasets = uicontrol(gcf,'Style','listbox','String','','Position',[350 90 130 70],'Tag','UIControl');

handles.PushMoveUp            = uicontrol(gcf,'Style','pushbutton','String','Move Up',       'Position',[520 140 100 20],'Tag','UIControl');
handles.PushMoveDown          = uicontrol(gcf,'Style','pushbutton','String','Move Down',     'Position',[520 115 100 20],'Tag','UIControl');
handles.PushRemoveUsedDataset = uicontrol(gcf,'Style','pushbutton','String','Remove Dataset','Position',[520  90 100 20],'Tag','UIControl');

uipanel('Title','Interpolation Limits','Units','pixels','Position',[350 30 270 50],'Tag','UIControl');
handles.EditZMax              = uicontrol(gcf,'Style','edit','String','','Position',[420 40 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditZMin              = uicontrol(gcf,'Style','edit','String','','Position',[530 40 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextZMax              = uicontrol(gcf,'Style','text','String','Z max (m)','Position',[360 36 55 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextZMin              = uicontrol(gcf,'Style','text','String','Z min (m)','Position',[470 36 55 20],'HorizontalAlignment','right','Tag','UIControl');

uipanel('Title','New Dataset','Units','pixels','Position',[630 30 370 130],'Tag','UIControl');

handles.PushGenerateDataset   = uicontrol(gcf,'Style','pushbutton','String','Generate Dataset', 'Position',[880  40 110 20],'FontWeight','bold','Tag','UIControl');
handles.ToggleAutomaticLimits = uicontrol(gcf,'Style','checkbox',  'String','Automatic Limits', 'Position',[640  40 100 20],'Tag','UIControl');
handles.PushDrawBBox          = uicontrol(gcf,'Style','pushbutton','String','Draw Bounding Box','Position',[750  40 110 20],'Tag','UIControl');

handles.EditXMax              = uicontrol(gcf,'Style','edit','String','','Position',[675 130 60 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditXMin              = uicontrol(gcf,'Style','edit','String','','Position',[675 105 60 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditDX                = uicontrol(gcf,'Style','edit','String','','Position',[675  80 60 20],'HorizontalAlignment','right','Tag','UIControl');

handles.EditYMax              = uicontrol(gcf,'Style','edit','String','','Position',[780 130 60 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditYMin              = uicontrol(gcf,'Style','edit','String','','Position',[780 105 60 20],'HorizontalAlignment','right','Tag','UIControl');
handles.EditDY                = uicontrol(gcf,'Style','edit','String','','Position',[780  80 60 20],'HorizontalAlignment','right','Tag','UIControl');

handles.TextXMax              = uicontrol(gcf,'Style','text','String','X Max','Position',[635 126 35 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextXMin              = uicontrol(gcf,'Style','text','String','X Min','Position',[635 101 35 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextDX                = uicontrol(gcf,'Style','text','String','dX',   'Position',[635  76 35 20],'HorizontalAlignment','right','Tag','UIControl');

handles.TextYMax              = uicontrol(gcf,'Style','text','String','Y Max','Position',[740 126 35 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextYMin              = uicontrol(gcf,'Style','text','String','Y Min','Position',[740 101 35 20],'HorizontalAlignment','right','Tag','UIControl');
handles.TextDY               = uicontrol(gcf,'Style','text','String','dY',   'Position',[740  76 35 20],'HorizontalAlignment','right','Tag','UIControl');

set(handles.ListDatasets,     'CallBack',{@ListDatasets_Callback});
set(handles.PushAddDataset,   'CallBack',{@PushAddDataset_Callback});
set(handles.PushUseDataset,   'CallBack',{@PushUseDataset_Callback});
set(handles.PushRemoveDataset,'CallBack',{@PushRemoveDataset_Callback});
set(handles.PushEditDetails,  'CallBack',{@PushEditDetails_Callback});

set(handles.ListUsedDatasets,     'CallBack',{@ListUsedDatasets_Callback});
set(handles.PushMoveUp,           'CallBack',{@PushMoveUp_Callback});
set(handles.PushMoveDown,         'CallBack',{@PushMoveDown_Callback});
set(handles.PushRemoveUsedDataset,'CallBack',{@PushRemoveUsedDataset_Callback});
set(handles.EditZMax,             'CallBack',{@EditZMax_Callback});
set(handles.EditZMin,             'CallBack',{@EditZMin_Callback});
set(handles.EditXMax,             'CallBack',{@EditXMax_Callback});
set(handles.EditXMin,             'CallBack',{@EditXMin_Callback});
set(handles.EditDX,               'CallBack',{@EditDX_Callback});
set(handles.EditYMax,             'CallBack',{@EditYMax_Callback});
set(handles.EditYMin,             'CallBack',{@EditYMin_Callback});
set(handles.EditDY,               'CallBack',{@EditDY_Callback});
set(handles.ToggleAutomaticLimits,'CallBack',{@ToggleAutomaticLimits_Callback});
set(handles.PushGenerateDataset,  'CallBack',{@PushGenerateDataset_Callback});

SetUIBackgroundColors;

guidata(findobj('Tag','MainWindow'),handles);

RefreshAll(handles);

%%
function ListDatasets_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
handles.Bathymetry.ActiveDataset=get(hObject,'Value');
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushAddDataset_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));

filterspec=       {'*.mat', 'Mat File'; ...
    '*.xyz', 'Samples file (*.xyz)'};

[filename, pathname, filterindex] = uigetfile(filterspec);

if filterindex>0
    
    handles.Bathymetry.NrDatasets=handles.Bathymetry.NrDatasets+1;
    ii=handles.Bathymetry.NrDatasets;
    handles.Bathymetry.ActiveDataset=ii;
    handles.Bathymetry.Datasets{ii}=filename;
    handles.Bathymetry.Dataset(ii).Name=filename;
    handles.Bathymetry.Dataset(ii).FileName=filename;
    handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Name=handles.CoordinateSystem.Name;
    handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type=handles.CoordinateSystem.Type;
    handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Name='Mean Sea Level';
    handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Level=0;
    handles.Bathymetry.Dataset(ii).Edit=1;
    
    switch filterindex,
        case 1
            % Mat File
            d=load([pathname filename]);
            if isfield(d,'Comments')
                handles.Bathymetry.Dataset(ii).Comments=d.Comments;
            else
                handles.Bathymetry.Dataset(ii).Comments={'none'};
            end
            handles.Bathymetry.Dataset(ii).Type=d.Type;
            handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Name=d.HorizontalCoordinateSystem.Name;
            handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type=d.HorizontalCoordinateSystem.Type;
            handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Name=d.VerticalCoordinateSystem.Name;
            handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Level=d.VerticalCoordinateSystem.Level;
            handles.Bathymetry.Dataset(ii).x=d.x;
            handles.Bathymetry.Dataset(ii).y=d.y;
            handles.Bathymetry.Dataset(ii).z=d.z;
        case 2
            % XYZ File
            handles=ddb_openXYZFile(handles,ii);
            guidata(findobj('Tag','MainWindow'),handles);
            ddb_editBathymetryDetails;
            handles=guidata(findobj('Tag','MainWindow'));
    end
    RefreshAll(handles);
    guidata(findobj('Tag','MainWindow'),handles);
end

%%
function PushUseDataset_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
ii=handles.Bathymetry.ActiveDataset;
handles.Bathymetry.NrUsedDatasets=handles.Bathymetry.NrUsedDatasets+1;
nr=handles.Bathymetry.NrUsedDatasets;
handles.Bathymetry.UsedDataset(nr).Name=handles.Bathymetry.Dataset(ii).Name;
handles.Bathymetry.UsedDataset(nr).ZMin=-10000;
handles.Bathymetry.UsedDataset(nr).ZMax=10000;
handles.Bathymetry.UsedDatasets{nr}=handles.Bathymetry.UsedDataset(nr).Name;
handles.Bathymetry.ActiveUsedDataset=nr;
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushRemoveDataset_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
Dataset=handles.Bathymetry.Dataset;
[Dataset,iac,nr]=UpDownDeleteStruc(Dataset,handles.Bathymetry.ActiveDataset,'delete');
handles.Bathymetry.Dataset=Dataset;
handles.Bathymetry.NrDatasets=nr;
handles.Bathymetry.Datasets=[];
for i=1:nr
    handles.Bathymetry.Datasets{i}=handles.Bathymetry.Dataset(i).Name;
end
handles.Bathymetry.ActiveDataset=max(iac,1);
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushEditDetails_Callback(hObject,eventdata)
ddb_editBathymetryDetails;
handles=guidata(findobj('Tag','MainWindow'));
RefreshAll(handles);

%%
function ListUsedDatasets_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
handles.Bathymetry.ActiveUsedDataset=get(hObject,'Value');
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushMoveUp_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
UsedDataset=handles.Bathymetry.UsedDataset;
[UsedDataset,iac,nr]=UpDownDeleteStruc(UsedDataset,handles.Bathymetry.ActiveUsedDataset,'up');
handles.Bathymetry.UsedDataset=UsedDataset;
for i=1:nr
    handles.Bathymetry.UsedDatasets{i}=handles.Bathymetry.UsedDataset(i).Name;
end
handles.Bathymetry.ActiveUsedDataset=iac;
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushMoveDown_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
UsedDataset=handles.Bathymetry.UsedDataset;
[UsedDataset,iac,nr]=UpDownDeleteStruc(UsedDataset,handles.Bathymetry.ActiveUsedDataset,'down');
handles.Bathymetry.UsedDataset=UsedDataset;
for i=1:nr
    handles.Bathymetry.UsedDatasets{i}=handles.Bathymetry.UsedDataset(i).Name;
end
handles.Bathymetry.ActiveUsedDataset=iac;
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushRemoveUsedDataset_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
UsedDataset=handles.Bathymetry.UsedDataset;
[UsedDataset,iac,nr]=UpDownDeleteStruc(UsedDataset,handles.Bathymetry.ActiveUsedDataset,'delete');
handles.Bathymetry.UsedDataset=UsedDataset;
handles.Bathymetry.NrUsedDatasets=nr;
handles.Bathymetry.UsedDatasets=[];
for i=1:nr
    handles.Bathymetry.UsedDatasets{i}=handles.Bathymetry.UsedDataset(i).Name;
end
handles.Bathymetry.ActiveUsedDataset=max(iac,1);
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditZMin_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
jj=handles.Bathymetry.ActiveUsedDataset;
str=get(hObject,'String');
handles.Bathymetry.UsedDataset(jj).ZMin=str2double(str);
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditZMax_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
jj=handles.Bathymetry.ActiveUsedDataset;
str=get(hObject,'String');
handles.Bathymetry.UsedDataset(jj).ZMax=str2double(str);
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditXMin_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.XMin=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditXMax_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.XMax=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditDX_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.dX=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditYMin_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.YMin=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditYMax_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.YMax=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function EditDY_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
str=get(hObject,'String');
handles.Bathymetry.NewDataset.dY=str2double(str);
guidata(findobj('Tag','MainWindow'),handles);

%%
function ToggleAutomaticLimits_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
ii=get(hObject,'Value');
handles.Bathymetry.NewDataset.AutoLimits=ii;
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);

%%
function PushGenerateDataset_Callback(hObject,eventdata)

handles=guidata(findobj('Tag','MainWindow'));
handles=ddb_generateNewBathymetryDataset(handles);
RefreshAll(handles);
guidata(findobj('Tag','MainWindow'),handles);


%%
function RefreshAll(handles)

Bathy=handles.Bathymetry;

if Bathy.NrDatasets>0
    
    set(handles.PushUseDataset,          'Enable','on');
    set(handles.PushRemoveDataset ,      'Enable','on');
    
    ii=Bathy.ActiveDataset;
    
    set(handles.ListDatasets,'Value',1);
    set(handles.ListDatasets,'String',Bathy.Datasets);
    set(handles.ListDatasets,'Value',Bathy.ActiveDataset);
    
    set(handles.TextHorizontalCoordinateSystem,'String',[Bathy.Dataset(ii).HorizontalCoordinateSystem.Name ' - ' Bathy.Dataset(ii).HorizontalCoordinateSystem.Type]);
    set(handles.TextVerticalCoordinateSystem,  'String',[Bathy.Dataset(ii).VerticalCoordinateSystem.Name '  (M.S.L. ' num2str(Bathy.Dataset(ii).VerticalCoordinateSystem.Level) ' m)']);
    
    k=strmatch(Bathy.Dataset(ii).Name,Bathy.UsedDatasets,'exact');
    if ~isempty(k)
        set(handles.PushUseDataset,   'Enable','off');
        set(handles.PushRemoveDataset,'Enable','off');
    end
    
    if ~Bathy.Dataset(ii).Edit
        set(handles.PushRemoveDataset, 'Enable','off');
    end
    
    jj=Bathy.ActiveUsedDataset;
    set(handles.ListUsedDatasets,'Value',jj);
    set(handles.ListUsedDatasets,'String',Bathy.UsedDatasets);
    
    if Bathy.NrUsedDatasets>0
        set(handles.EditZMax,'String',num2str(Bathy.UsedDataset(jj).ZMax),'Enable','on');
        set(handles.EditZMin,'String',num2str(Bathy.UsedDataset(jj).ZMin),'Enable','on');
        set(handles.TextZMax,'Enable','on');
        set(handles.TextZMin,'Enable','on');
        set(handles.PushGenerateDataset,'Enable','on');
    else
        set(handles.EditZMax,'String','','Enable','off');
        set(handles.EditZMin,'String','','Enable','off');
        set(handles.TextZMax,'Enable','off');
        set(handles.TextZMin,'Enable','off');
        set(handles.PushGenerateDataset,'Enable','off');
    end
    
    set(handles.EditXMax,'String',num2str(Bathy.NewDataset.XMax));
    set(handles.EditXMin,'String',num2str(Bathy.NewDataset.XMin));
    set(handles.EditDX,  'String',num2str(Bathy.NewDataset.dX));
    set(handles.EditYMax,'String',num2str(Bathy.NewDataset.YMax));
    set(handles.EditYMin,'String',num2str(Bathy.NewDataset.YMin));
    set(handles.EditDY,  'String',num2str(Bathy.NewDataset.dY));
    
    set(handles.ToggleAutomaticLimits,'Value',Bathy.NewDataset.AutoLimits);
    
    if Bathy.NewDataset.AutoLimits
        set(handles.EditXMax,'Enable','off');
        set(handles.EditXMin,'Enable','off');
        %         set(handles.EditDX,  'Enable','off');
        set(handles.EditYMax,'Enable','off');
        set(handles.EditYMin,'Enable','off');
        %         set(handles.EditDY,  'Enable','off');
        set(handles.TextXMax,'Enable','off');
        set(handles.TextXMin,'Enable','off');
        %         set(handles.TextDX,  'Enable','off');
        set(handles.TextYMax,'Enable','off');
        set(handles.TextYMin,'Enable','off');
        %         set(handles.TextDY,  'Enable','off');
        set(handles.PushDrawBBox,  'Enable','off');
    else
        set(handles.EditXMax,'Enable','on');
        set(handles.EditXMin,'Enable','on');
        %         set(handles.EditDX,  'Enable','on');
        set(handles.EditYMax,'Enable','on');
        set(handles.EditYMin,'Enable','on');
        %         set(handles.EditDY,  'Enable','on');
        set(handles.TextXMax,'Enable','on');
        set(handles.TextXMin,'Enable','on');
        %         set(handles.TextDX,  'Enable','on');
        set(handles.TextYMax,'Enable','on');
        set(handles.TextYMin,'Enable','on');
        %         set(handles.TextDY,  'Enable','on');
        set(handles.PushDrawBBox,  'Enable','on');
    end
end

