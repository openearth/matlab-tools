function ddb_editD3DFlowViscosity
%DDB_EDITD3DFLOWVISCOSITY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowViscosity
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowViscosity
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
ddb_refreshScreen('Phys. Parameters','Viscosity');
handles=getHandles;
bgc=get(gcf,'Color');

uipanel('Title','Background Horizontal Viscosity / Diffusivity','Units','pixels','Position',[60 30 290 125],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleFile  = uicontrol(gcf,'Style','radiobutton', 'String','File','Position',[70 115 50 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.PushSelectFile  = uicontrol(gcf,'Style','pushbutton', 'String','File','Position',[120 115 60 20],'Tag','UIControl');
handles.GUIHandles.TextFile  = uicontrol(gcf,'Style','text','String','','Position',[185 111 60 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleUniform  = uicontrol(gcf,'Style','radiobutton', 'String','Uniform','Position',[70 90 60 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.EditVicoUV  = uicontrol(gcf,'Style','edit','String','0.0','Position',[245 65 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDicoUV  = uicontrol(gcf,'Style','edit','String','0.0','Position',[245 40 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextVicoUV  = uicontrol(gcf,'Style','text','String','Horizontal Eddy Viscosity (m^2/s)','Position',[70 61 170 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextDicoUV  = uicontrol(gcf,'Style','text','String','Horizontal Eddy Diffusivity (m^2/s)','Position',[70 36 170 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');

uipanel('Title','Model for 2D Turbulence','Units','pixels','Position',[360 30 150 125],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleHLES = uicontrol(gcf,'Style','checkbox', 'String','Subgrid scale HLES','Position',[370 115 130 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.Pushddb_editHLES  = uicontrol(gcf,'Style','pushbutton','String','Edit','Position',[370 85 60 20],'Tag','UIControl');

uipanel('Title','Background Vertical Viscosity / Diffusivity','Units','pixels','Position',[520 30 260 125],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.EditVicoWW  = uicontrol(gcf,'Style','edit','String','0.0','Position',[700 115 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDicoWW  = uicontrol(gcf,'Style','edit','String','0.0','Position',[700  85 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditOzmidov = uicontrol(gcf,'Style','edit','String','0.0','Position',[700  55 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextVicoWW  = uicontrol(gcf,'Style','text','String','Vertical Eddy Viscosity (m^2/s)','Position',[530 111 170 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextDicoWW  = uicontrol(gcf,'Style','text','String','Vertical Eddy Diffusivity (m^2/s)','Position',[530 81 170 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextOzmidov = uicontrol(gcf,'Style','text','String','Ozmidov Length Scale (m)','Position',[530 51 170 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');

uipanel('Title','Model for 3D Turbulence','Units','pixels','Position',[790 30 150 125],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleConstant  = uicontrol(gcf,'Style','radiobutton', 'String','Constant','Position',[800 115 65 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleAlgebraic = uicontrol(gcf,'Style','radiobutton', 'String','Algebraic','Position',[800  90 65 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleKL        = uicontrol(gcf,'Style','radiobutton', 'String','K-L','Position',[800 65 65 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.ToggleKEpsilon  = uicontrol(gcf,'Style','radiobutton', 'String','K-Epsilon','Position',[800  40 65 20],'BackgroundColor',bgc,'Tag','UIControl');

set(handles.GUIHandles.EditVicoUV,'CallBack',    {@EditVicoUV_CallBack});
set(handles.GUIHandles.EditDicoUV,'CallBack',    {@EditDicoUV_CallBack});
set(handles.GUIHandles.EditVicoWW,'CallBack',    {@EditVicoWW_CallBack});
set(handles.GUIHandles.EditDicoWW,'CallBack',    {@EditDicoWW_CallBack});
set(handles.GUIHandles.EditOzmidov,'CallBack',   {@EditOzmidov_CallBack});
set(handles.GUIHandles.ToggleUniform,'CallBack', {@ToggleUniform_CallBack});
set(handles.GUIHandles.ToggleFile,'CallBack',    {@ToggleFile_CallBack});
set(handles.GUIHandles.PushSelectFile,'CallBack',{@PushSelectFile_CallBack});
set(handles.GUIHandles.ToggleHLES,'CallBack',    {@ToggleHLES_CallBack});
set(handles.GUIHandles.Pushddb_editHLES,'CallBack',  {@Pushddb_editHLES_CallBack});

set(handles.GUIHandles.ToggleConstant,'CallBack', {@ToggleConstant_CallBack});
set(handles.GUIHandles.ToggleAlgebraic,'CallBack',{@ToggleAlgebraic_CallBack});
set(handles.GUIHandles.ToggleKL,'CallBack',       {@ToggleKL_CallBack});
set(handles.GUIHandles.ToggleKEpsilon,'CallBack', {@ToggleKEpsilon_CallBack});

SetUIBackgroundColors;

setHandles(handles);

RefreshViscosity(handles);


%%
function EditVicoUV_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VicoUV=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDicoUV_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).DicoUV=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditVicoWW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VicoWW=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDicoWW_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).DicoWW=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditOzmidov_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Xlo=str2num(get(hObject,'String'));
setHandles(handles);

%%
function ToggleFile_CallBack(hObject,eventdata)
handles=getHandles;
if get(hObject,'Value')==1
    handles.Model(md).Input(ad).UniformViscosity=0;
end
RefreshViscosity(handles);
setHandles(handles);

%%
function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
if get(hObject,'Value')==1
    handles.Model(md).Input(ad).UniformViscosity=1;
end
RefreshViscosity(handles);
setHandles(handles);

%%
function PushSelectFile_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.edy', 'Select Viscosity File');
if ~pathname==0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).EdyFile=filename;
    RefreshViscosity(handles);
end
setHandles(handles);

%%
function ToggleConstant_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VerticalTurbulenceModel='Constant';
RefreshViscosity(handles);
setHandles(handles);

%%
function ToggleAlgebraic_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VerticalTurbulenceModel='Algebraic';
RefreshViscosity(handles);
setHandles(handles);

%%
function ToggleKL_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VerticalTurbulenceModel='K-L';
RefreshViscosity(handles);
setHandles(handles);

%%
function ToggleKEpsilon_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).VerticalTurbulenceModel='K-epsilon';
RefreshViscosity(handles);
setHandles(handles);

%%
function ToggleHLES_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).HLES=get(hObject,'Value');
RefreshViscosity(handles);
setHandles(handles);

%%
function Pushddb_editHLES_CallBack(hObject,eventdata)
handles=getHandles;
ddb_editHLES;
setHandles(handles);

%%
function RefreshViscosity(handles)

set(handles.GUIHandles.EditVicoUV,'String',num2str(handles.Model(md).Input(ad).VicoUV));
set(handles.GUIHandles.EditDicoUV,'String',num2str(handles.Model(md).Input(ad).DicoUV));

set(handles.GUIHandles.EditVicoWW, 'String',num2str(handles.Model(md).Input(ad).VicoWW));
set(handles.GUIHandles.EditDicoWW, 'String',num2str(handles.Model(md).Input(ad).DicoWW));
set(handles.GUIHandles.EditOzmidov,'String',num2str(handles.Model(md).Input(ad).Xlo));

set(handles.GUIHandles.TextFile,'String',['File : ' handles.Model(md).Input(ad).EdyFile]);
if handles.Model(md).Input(ad).UniformViscosity==0
    set(handles.GUIHandles.EditVicoUV,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextVicoUV,'Enable','off');
    set(handles.GUIHandles.EditDicoUV,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextDicoUV,'Enable','off');
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    set(handles.GUIHandles.ToggleFile,'Value',1);
    set(handles.GUIHandles.PushSelectFile,'Enable','on');
    set(handles.GUIHandles.TextFile,'Enable','on');
else
    set(handles.GUIHandles.EditVicoUV,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextVicoUV,'Enable','on');
    set(handles.GUIHandles.EditDicoUV,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextDicoUV,'Enable','on');
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleFile,'Value',0);
    set(handles.GUIHandles.PushSelectFile,'Enable','off');
    set(handles.GUIHandles.TextFile,'Enable','off');
end

if handles.Model(md).Input(ad).KMax==1
    set(handles.GUIHandles.EditVicoWW,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditDicoWW,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditOzmidov,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextVicoWW,'Enable','off');
    set(handles.GUIHandles.TextDicoWW,'Enable','off');
    set(handles.GUIHandles.TextOzmidov,'Enable','off');
    set(handles.GUIHandles.ToggleConstant,'Enable','off');
    set(handles.GUIHandles.ToggleAlgebraic,'Enable','off');
    set(handles.GUIHandles.ToggleKL,'Enable','off');
    set(handles.GUIHandles.ToggleKEpsilon,'Enable','off');
else
    set(handles.GUIHandles.EditVicoWW,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDicoWW,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditOzmidov,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextVicoWW,'Enable','on');
    set(handles.GUIHandles.TextDicoWW,'Enable','on');
    set(handles.GUIHandles.TextOzmidov,'Enable','on');
    set(handles.GUIHandles.ToggleConstant,'Enable','on');
    set(handles.GUIHandles.ToggleAlgebraic,'Enable','on');
    set(handles.GUIHandles.ToggleKL,'Enable','on');
    set(handles.GUIHandles.ToggleKEpsilon,'Enable','on');
end

if handles.Model(md).Input(ad).HLES
    set(handles.GUIHandles.ToggleHLES,'Value',1);
    set(handles.GUIHandles.Pushddb_editHLES,'Enable','on');
else
    set(handles.GUIHandles.ToggleHLES,'Value',0);
    set(handles.GUIHandles.Pushddb_editHLES,'Enable','off');
end

set(handles.GUIHandles.ToggleConstant,'Value',0);
set(handles.GUIHandles.ToggleAlgebraic,'Value',0);
set(handles.GUIHandles.ToggleKL,'Value',0);
set(handles.GUIHandles.ToggleKEpsilon,'Value',0);
if handles.Model(md).Input(ad).KMax>1
    switch lower(deblank(handles.Model(md).Input(ad).VerticalTurbulenceModel))
        case{'constant'}
            set(handles.GUIHandles.ToggleConstant,'Value',1);
        case{'algebraic'}
            set(handles.GUIHandles.ToggleAlgebraic,'Value',1);
        case{'k-l'}
            set(handles.GUIHandles.ToggleKL,'Value',1);
        case{'k-epsilon'}
            set(handles.GUIHandles.ToggleKEpsilon,'Value',1);
    end
end


