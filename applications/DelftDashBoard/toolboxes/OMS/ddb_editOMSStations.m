function ddb_editOMSStations
%DDB_EDITOMSSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editOMSStations
%
%   Input:

%
%
%
%
%   Example
%   ddb_editOMSStations
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ddb_refreshScreen('Toolbox','Stations');

handles=getHandles;

ddb_plotOMS(handles,'activate');

if ~isfield(handles.Toolbox(tb),'UseObservationsDatabase')
    jj=strmatch('ObservationsDatabase',{handles.Toolbox(:).Name},'exact');
    handles.Toolbox(tb).UseObservationsDatabase=zeros(length(handles.Toolbox(jj).Databases),1);
end

if ~isfield(handles.Toolbox(tb),'UseTideDatabase')
    jj=strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact');
    handles.Toolbox(tb).UseTideDatabase=zeros(length(handles.Toolbox(jj).Databases),1);
end

str{1}='';
for i=1:handles.Toolbox(tb).NrStations
    str{i}=handles.Toolbox(tb).Stations(i).LongName;
end
handles.GUIHandles.ListOMSStations = uicontrol(gcf,'Style','listbox','String',str,   'Position',   [ 60  60 200 90],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.ListOMSStations,'Value',handles.Toolbox(tb).ActiveStation);

jj=strmatch('ObservationsDatabase',{handles.Toolbox(:).Name},'exact');
posy=130;
for k=1:length(handles.Toolbox(jj).Databases)
    handles.GUIHandles.UseObservationsDatabase(k) = uicontrol(gcf,'Style','checkbox','String',handles.Toolbox(jj).Databases{k},   'Position',   [280  posy 80 20],'Tag','UIControl','UserData',k);
    set(handles.GUIHandles.UseObservationsDatabase(k),'Callback',{@UseObservationsDatabase_Callback});
    set(handles.GUIHandles.UseObservationsDatabase(k),'Value',handles.Toolbox(tb).UseObservationsDatabase(k));
    posy=posy-20;
end

jj=strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact');
posy=130;
for k=1:length(handles.Toolbox(jj).Databases)
    handles.GUIHandles.UseTideDatabase(k) = uicontrol(gcf,'Style','checkbox','String',handles.Toolbox(jj).Databases{k},   'Position',   [360  posy 80 20],'Tag','UIControl','UserData',k);
    set(handles.GUIHandles.UseTideDatabase(k),'Callback',{@UseTideDatabase_Callback});
    set(handles.GUIHandles.UseTideDatabase(k),'Value',handles.Toolbox(tb).UseTideDatabase(k));
    posy=posy-20;
end

handles.GUIHandles.PushAddStation = uicontrol(gcf,'Style','pushbutton','String','Add','Position',   [60 30 50  20],'Tag','UIControl');
handles.GUIHandles.PushDeleteStation = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',   [120 30 50  20],'Tag','UIControl');

handles.GUIHandles.PushAddStations = uicontrol(gcf,'Style','pushbutton','String','Add Stations','Position',   [280 30 100  20],'Tag','UIControl');

omsparameters={'Hs','Tp','WavDir','WL'};

posy=125;
for i=1:length(omsparameters)
    handles.GUIHandles.TextParameter(i) = uicontrol(gcf,'Style','text','String',omsparameters{i},'Position',[440 posy-4 40 20],'HorizontalAlignment','left','UserData',i,'Tag','UIControl');
    handles.GUIHandles.PlotCmp(i)       = uicontrol(gcf,'Style','checkbox','Position',[490 posy 15 20],'UserData',i,'Tag','UIControl');
    handles.GUIHandles.PlotObs(i)       = uicontrol(gcf,'Style','checkbox','Position',[515 posy 15 20],'UserData',i,'Tag','UIControl');
    handles.GUIHandles.ObsSrc(i)        = uicontrol(gcf,'Style','edit','Position',[540 posy 50 20],'HorizontalAlignment','left','UserData',i,'Tag','UIControl');
    handles.GUIHandles.ObsID(i)         = uicontrol(gcf,'Style','edit','Position',[595 posy 50 20],'HorizontalAlignment','left','UserData',i,'Tag','UIControl');
    handles.GUIHandles.PlotPrd(i)       = uicontrol(gcf,'Style','checkbox','Position',[650 posy 15 20],'UserData',i,'Tag','UIControl');
    handles.GUIHandles.PrdSrc(i)        = uicontrol(gcf,'Style','edit','Position',[675 posy 50 20],'HorizontalAlignment','left','UserData',i,'Tag','UIControl');
    handles.GUIHandles.PrdID(i)         = uicontrol(gcf,'Style','edit','Position',[730 posy 50 20],'HorizontalAlignment','left','UserData',i,'Tag','UIControl');
    posy=posy-25;
end
handles.GUIHandles.StoreSP2       = uicontrol(gcf,'Style','checkbox','String','2D spectra','Position',[790 125 80 20],'Tag','UIControl');
handles.GUIHandles.SP2id          = uicontrol(gcf,'Style','edit','String','','Position',[870 125 30 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.SelectType     = uicontrol(gcf,'Style','popupmenu','String',{'wavebuoy','tidegauge','meteostation'},'Position',[790 95 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.PushAddStations,'Callback',{@PushAddStations_Callback});
set(handles.GUIHandles.PushAddStation,'Callback',{@PushAddStation_Callback});
set(handles.GUIHandles.PushDeleteStation,'Callback',{@PushDeleteStation_Callback});
set(handles.GUIHandles.ListOMSStations,'Callback',{@ListOMSStations_Callback});
set(handles.GUIHandles.StoreSP2,'Callback',{@StoreSP2_Callback});
set(handles.GUIHandles.SP2id,'Callback',{@SP2id_Callback});
set(handles.GUIHandles.SelectType,'Callback',{@SelectType_Callback});

for i=1:length(omsparameters)
    set(handles.GUIHandles.PlotCmp(i),'Callback',{@PlotCmp_Callback});
    set(handles.GUIHandles.PlotObs(i),'Callback',{@PlotObs_Callback});
    set(handles.GUIHandles.ObsSrc(i),'Callback',{@ObsSrc_Callback});
    set(handles.GUIHandles.ObsID(i),'Callback',{@ObsID_Callback});
    set(handles.GUIHandles.PlotPrd(i),'Callback',{@PlotPrd_Callback});
    set(handles.GUIHandles.PrdSrc(i),'Callback',{@PrdSrc_Callback});
    set(handles.GUIHandles.PrdID(i),'Callback',{@PrdID_Callback});
end

SetUIBackgroundColors;

ddb_refreshOMSStations(handles);

setHandles(handles);

%%
function UseObservationsDatabase_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
handles.Toolbox(tb).UseObservationsDatabase(k)=get(hObject,'Value');
setHandles(handles);

%%
function UseTideDatabase_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
handles.Toolbox(tb).UseTideDatabase(k)=get(hObject,'Value');
setHandles(handles);

%%
function ListOMSStations_Callback(hObject,eventdata)

handles=getHandles;
handles.Toolbox(tb).ActiveStation=get(hObject,'Value');

h0=findobj(gca,'Tag','ActiveOMSStation');
delete(h0);
n=handles.Toolbox(tb).ActiveStation;
plt=plot3(handles.Toolbox(tb).Stations(n).x,handles.Toolbox(tb).Stations(n).y,1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveOMSStation');
set(handles.GUIHandles.ListOMSStations,'Value',handles.Toolbox(tb).ActiveStation);

ddb_refreshOMSStations(handles);
setHandles(handles);

%%
function PlotCmp_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).PlotCmp=ii;
setHandles(handles);

%%
function PlotObs_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).PlotObs=ii;
if ii==1
    set(handles.GUIHandles.ObsSrc(k),'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.ObsID(k),'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.GUIHandles.ObsSrc(k),'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.ObsID(k),'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
end
setHandles(handles);

%%
function PlotPrd_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).PlotPrd=ii;
if ii==1
    set(handles.GUIHandles.PrdSrc(k),'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.PrdID(k),'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.GUIHandles.PrdSrc(k),'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.PrdID(k),'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
end
setHandles(handles);

%%
function ObsSrc_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).ObsSrc=get(hObject,'String');
setHandles(handles);

%%
function ObsID_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).ObsID=get(hObject,'String');
setHandles(handles);

%%
function PrdSrc_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).PrdSrc=get(hObject,'String');
setHandles(handles);

%%
function PrdID_Callback(hObject,eventdata)
handles=getHandles;
k=get(hObject,'UserData');
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).Parameters(k).PrdID=get(hObject,'String');
setHandles(handles);

%%
function StoreSP2_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).StoreSP2=get(hObject,'Value');

if handles.Toolbox(tb).Stations(iac).StoreSP2
    set(handles.GUIHandles.SP2id,'BackgroundColor',[1 1 1],'Enable','on');
else
    set(handles.GUIHandles.SP2id,'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
end

setHandles(handles);

%%
function SP2id_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveStation;
handles.Toolbox(tb).Stations(iac).SP2id=get(hObject,'String');
setHandles(handles);

%%
function SelectType_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveStation;
str=get(hObject,'String');
i=get(hObject,'Value');
handles.Toolbox(tb).Stations(iac).Type=str{i};
setHandles(handles);

%%
function PushAddStation_Callback(hObject,eventdata)

handles=getHandles;
% iac=handles.Toolbox(tb).ActiveOMSStation+1;
setHandles(handles);

%%
function PushDeleteStation_Callback(hObject,eventdata)

handles=getHandles;
iac=handles.Toolbox(tb).ActiveStation;

Stations=handles.Toolbox(tb).Stations;

if handles.Toolbox(tb).NrStations==1
    handles.Toolbox(tb).Stations=[];
    handles.Toolbox(tb).NrStations=0;
else
    
    if iac==1
        Stations=Stations(2:end);
    elseif iac==handles.Toolbox(tb).NrStations
        Stations=Stations(1:end-1);
    else
        for i=iac:handles.Toolbox(tb).NrStations-1
            Stations(i)=Stations(i+1);
        end
        Stations=Stations(1:end-1);
    end
    
    handles.Toolbox(tb).Stations=Stations;
    
    if iac==handles.Toolbox(tb).NrStations
        handles.Toolbox(tb).ActiveStation=handles.Toolbox(tb).ActiveStation-1;
    end
    handles.Toolbox(tb).NrStations=handles.Toolbox(tb).NrStations-1;
end

str{1}='';
for i=1:handles.Toolbox(tb).NrStations
    str{i}=handles.Toolbox(tb).Stations(i).LongName;
end
set(handles.GUIHandles.ListOMSStations,'String',str,'Value',handles.Toolbox(tb).ActiveStation);

ddb_plotOMSStations(handles);

ddb_refreshOMSStations(handles);

setHandles(handles);

%%
function PushAddStations_Callback(hObject,eventdata)

handles=getHandles;

handles=ddb_addOMSObservationStations(handles);
handles=ddb_addOMSTideStations(handles);

str{1}='';
for i=1:handles.Toolbox(tb).NrStations
    str{i}=handles.Toolbox(tb).Stations(i).LongName;
end
set(handles.GUIHandles.ListOMSStations,'String',str,'Value',1);

handles.Toolbox(tb).ActiveOMSStation=1;

ddb_plotOMSStations(handles);

ddb_refreshOMSStations(handles);

setHandles(handles);


