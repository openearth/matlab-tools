function UCIT_plotAlongshore
%UCIT_PLOTALONGSHORE routine that starts GUI to plot parameters alongshore
%
%
%
% syntax:
%
%
% input:
%
% output:
%
% see also
%

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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


%% check whether overview figure is present
[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview figure (plotTransectOverview)','No map found');
    return
end

fig100=figure(100);clf;
set(fig100,'Units','normalized','visible','off');%,'Position',UCIT_getPlotPosition('UR',1));
set(fig100,'menubar','none','Resize','on','Resizefcn','UCIT_fncResizeUSGS');
set(fig100,'Position',UCIT_getPlotPosition('UR',1))
set(fig100,'Name','UCIT - Plot parameters alongshore','NumberTitle','Off','Units','characters');
set(fig100,'color','w');
set(fig100,'tag','USGSGUI');
figure(fig100);

mapWhandle = findobj('tag','UCIT_mainWin');
if ~isempty(mapWhandle) && strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
    [d] = UCIT_getLidarMetaData;
end

transects = d.transectID;
USGSParameters={'Significant wave height','Peak wave period','Wave length (L0)','Shoreline position','Shoreline change','Beach slope','Bias','Mean High Water Level'};


% Top panel
hpTop       = uipanel('Title','Transect Selection','Units','normalized','FontSize',12,'FontWeight','bold',...
    'BackgroundColor','w','Position',[.1 .55 .8 .4],'Bordertype','etchedout','Tag','Toppanel');

% Lower panel
hpBottom    = uipanel('Title','Parameter Selection','Units','normalized','FontSize',12,'FontWeight','bold',...
    'BackgroundColor','w','Position',[.1 0.1 .8 .4],'Bordertype','etchedout','Tag','Bottompanel');

% Text headers of top panel
UIControls.Handle(1)      = uicontrol('Parent',hpTop,'Style','text','units','normalized','String','Begintransect:','FontSize',10,...
    'Position',[0.05 0.75 0.3 0.1],'HorizontalAlignment','left', 'Tag','text1','BackgroundColor','w');
UIControls.Handle(2)       = uicontrol('Parent',hpTop,'Style','text','units','normalized','String','Endtransect:','FontSize',10,...
    'Position',[0.05 0.60 0.3 0.1],'HorizontalAlignment','left', 'Tag','text2', 'BackgroundColor','w');
UIControls.Handle(3)       = uicontrol('Parent',hpTop,'Style','text','units','normalized','String','or:','FontSize',10,...
    'Position',[0.05 0.45 0.3 0.1],'HorizontalAlignment','left', 'Tag','text3', 'BackgroundColor','w');

% Pulldownbox 1
UIControls.Handle(4)  = uicontrol('Parent',hpTop,'Style', 'popup','backgroundcolor','w','units','normalized', 'String', transects,'Tag','beginTransect','Position',[0.4 0.74 0.2 0.12]);

% Pulldownbox 2
UIControls.Handle(5)  = uicontrol('Parent',hpTop,'Style', 'popup','backgroundcolor','w','units','normalized', 'String', transects,'Tag','endTransect','Position',[0.4 0.58 0.2 0.12]);%,'Callback', 'clbPlotUSGS'

% Pushbutton of top panel
UIControls.Handle(6)    = uicontrol('Parent',hpTop,'Style','pushbutton','units','normalized','String','Select transects from overview',...
    'Position',[0.05 .2 .6 .15],'FontSize',10,'Enable','on','Tag','text4','Callback','UCIT_SelectTransectsUS');

% Listbox lower panel
UIControls.Handle(7)         = uicontrol('Parent',hpBottom,'Style','listbox','units','normalized','FontSize',8,'Enable','on',...
    'Position',[0.05 0.15 .45 .7],'BackgroundColor',[1 1 1],'HorizontalAlignment','right',...
    'String',USGSParameters,'max',2,'Tag','Input');

% Pushbutton 1 lower panel
UIControls.Handle(8)     = uicontrol('Parent',hpBottom,'Style','pushbutton','units','normalized','String','Plot',...
    'Position',[0.6 .17 .15 .2], 'FontSize',8,'FontWeight','bold','Enable','on','Tag','text6','Callback','UCIT_clbPlotUSGS');

% Pushbutton 2 lower panel

UIControls.Handle(8)     = uicontrol('Parent',hpBottom,'Style','pushbutton','units','normalized','String','Export',...
    'Position',[0.8 .17 .15 .2], 'FontSize',8,'FontWeight','bold','Enable','on','Tag','text7','Callback','UCIT_saveDataUS');

% Check box 1 lower panel
UIControls.Handle(9) = uicontrol('Parent',hpBottom,'Style','check','units','normalized','String',' Relative to lattitude',...
    'Position',[0.6 .75 .3 .15], 'FontSize',8,'Enable','on','Tag','lattitude','BackgroundColor',[1 1 1],'callback','UCIT_toggleCheckBoxes');

% Check box 2 lower panel
UIControls.Handle(9) = uicontrol('Parent',hpBottom,'Style','check','units','normalized','String',' Relative to reference line',...
    'Position',[0.6 .60 .3 .15], 'FontSize',8,'Enable','on','Tag','refline','BackgroundColor',[1 1 1],'callback','UCIT_toggleCheckBoxes');

% Check box 3 lower panel
UIControls.Handle(9) = uicontrol('Parent',hpBottom,'Style','check','units','normalized','String',' Flip horizontal axis',...
    'Position',[0.6 .45 .3 .15], 'FontSize',8,'Enable','on','Tag','flipaxis','BackgroundColor',[1 1 1],'callback','UCIT_toggleCheckBoxes');

set(fig100,'visible','on')

% Workaround wierd bug 
for k = 1:24
    a =  findobj('tag',['text' num2str(k)]);
    set(a,'fontsize',8)
end
