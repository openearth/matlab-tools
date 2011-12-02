function varargout = ddb_UCITToolbox(varargin)
%DDB_UCITTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_UCITToolbox(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_UCITToolbox
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
handles=getHandles;
ddb_plotUCIT(handles,'activate');

box_x=20;
box_y=20;
box_w=990;
box_h=160;
hp = uipanel('Title','UCIT','Units','pixels','Position',[box_x box_y box_w box_h],'Tag','UIControl');

%% set transects popups
box_x=30;box_y=30;box_w=210;box_h=135;
hp = uipanel('Title','Transects','Units','pixels','Position',[box_x box_y box_w box_h],'Tag','UIControl');
box_w=100;box_h=15;
handles.Transects1text= uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Datatype:'                  ,   'Position',[box_x+05 box_y+100 box_w box_h],'HorizontalAlignment','left');
handles.Transects1    = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Jarkus Data'                ,   'Position',[box_x+85 box_y+100 box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','TransectsDatatype',     'callback','UCIT_DC_loadRelevantInfo2Popup(1,2);');
handles.Transects2text= uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Area:'                      ,   'Position',[box_x+05 box_y+80  box_w box_h],'HorizontalAlignment','left');
handles.Transects2    = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Noord-Holland'              ,   'Position',[box_x+85 box_y+80  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','TransectsArea',         'callback','UCIT_DC_loadRelevantInfo2Popup(1,3);');
handles.Transects3text= uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Transect ID:'               ,   'Position',[box_x+05 box_y+60  box_w box_h],'HorizontalAlignment','left');
handles.Transects3    = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','04000'                      ,   'Position',[box_x+85 box_y+60  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','TransectsTransectID',   'callback','UCIT_DC_loadRelevantInfo2Popup(1,4);');
handles.Transects4text= uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Sounding ID:'               ,   'Position',[box_x+05 box_y+40  box_w box_h],'HorizontalAlignment','left');
handles.Transects4    = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','2006'                       ,   'Position',[box_x+85 box_y+40  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','TransectsSoundingID');
handles.Transects5text= uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Actions:'                   ,   'Position',[box_x+05 box_y+20  box_w box_h],'HorizontalAlignment','left');
handles.Transects5    = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','displayTransectsOnOverview' ,   'Position',[box_x+85 box_y+20  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','TrActions',            'callback','UCIT_DC_takeAction(1);');

%% set grids popups
box_x=270;box_y=30;box_w=210;box_h=135;
hp = uipanel('Title','Grids','Units','pixels','Position',[box_x box_y box_w box_h],'Tag','UIControl');
box_w=100;box_h=15;
handles.Grids1text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Datatype:'                  ,   'Position',[box_x+05 box_y+100 box_w box_h],'HorizontalAlignment','left');
handles.Grids1        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Kaartblad Vaklodingen'      ,   'Position',[box_x+85 box_y+100 box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','GridsDatatype',     'callback','UCIT_DC_loadRelevantInfo2Popup(2,2);');
handles.Grids2text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Name:'                      ,   'Position',[box_x+05 box_y+80  box_w box_h],'HorizontalAlignment','left');
handles.Grids2        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','KB117.4140'                 ,   'Position',[box_x+85 box_y+80  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','GridsName',         'callback','UCIT_DC_loadRelevantInfo2Popup(2,3);');
handles.Grids3text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Interval:'                  ,   'Position',[box_x+05 box_y+60  box_w box_h],'HorizontalAlignment','left');
handles.Grids3        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','2005'                       ,   'Position',[box_x+85 box_y+60  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','GridsInterval',     'callback','UCIT_DC_loadRelevantInfo2Popup(2,4);');
handles.Grids4text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Sounding ID:'               ,   'Position',[box_x+05 box_y+40  box_w box_h],'HorizontalAlignment','left');
handles.Grids4        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','0101'                       ,   'Position',[box_x+85 box_y+40  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','GridsSoundingID');
handles.Grids5text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Actions:'                   ,   'Position',[box_x+05 box_y+20  box_w box_h],'HorizontalAlignment','left');
handles.Grids5        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','displayAllGridoutlines'     ,   'Position',[box_x+85 box_y+20  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','GrActions',         'callback','UCIT_DC_takeAction(2);');

%% set points popups
box_x=510;box_y=30;box_w=210;box_h=135;
hp = uipanel('Title','Lines','Units','pixels','Position',[box_x box_y box_w box_h],'Tag','UIControl');
box_w=100;box_h=15;
handles.Lines1text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Datatype:'                  ,   'Position',[box_x+05 box_y+100 box_w box_h],'HorizontalAlignment','left');
handles.Lines1        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Dutch Beach Lines'          ,   'Position',[box_x+85 box_y+100 box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','LinesDatatype',    'callback','UCIT_DC_loadRelevantInfo2Popup(3,2);');
handles.Lines2text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Area:'                      ,   'Position',[box_x+05 box_y+80  box_w box_h],'HorizontalAlignment','left');
handles.Lines2        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Noord-Holland'              ,   'Position',[box_x+85 box_y+80  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','LinesArea',        'callback','UCIT_DC_loadRelevantInfo2Popup(3,3);');
handles.Lines3text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Sounding ID:'               ,   'Position',[box_x+05 box_y+60  box_w box_h],'HorizontalAlignment','left');
handles.Lines3        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','1843'                       ,   'Position',[box_x+85 box_y+60  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','LinesSoundingID',  'callback','UCIT_DC_loadRelevantInfo2Popup(3,4);');
handles.Lines4text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Line ID:'                   ,   'Position',[box_x+05 box_y+40  box_w box_h],'HorizontalAlignment','left');
handles.Lines4        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','All'                        ,   'Position',[box_x+85 box_y+40  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','LinesLineID');
handles.Lines5text    = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Actions:'                   ,   'Position',[box_x+05 box_y+20  box_w box_h],'HorizontalAlignment','left');
handles.Lines5        = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Select action ...'          ,   'Position',[box_x+85 box_y+20  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','LnActions',        'callback','UCIT_DC_takeAction(3);');

%% set lines popups
box_x=750;box_y=30;box_w=210;box_h=135;
hp = uipanel('Title','Points','Units','pixels','Position',[box_x box_y box_w box_h],'Tag','UIControl');
box_w=100;box_h=15;
handles.Points1text   = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Datatype:'                  ,   'Position',[box_x+05 box_y+100 box_w box_h],'HorizontalAlignment','left');
handles.Points1       = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Dutch offshore data'        ,   'Position',[box_x+85 box_y+100 box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','PointsDatatype',   'callback','UCIT_DC_loadRelevantInfo2Popup(4,2);');
handles.Points2text   = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Station:'                   ,   'Position',[box_x+05 box_y+80  box_w box_h],'HorizontalAlignment','left');
handles.Points2       = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Lichteiland Goeree'         ,   'Position',[box_x+85 box_y+80  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','PointsStation',    'callback','UCIT_DC_loadRelevantInfo2Popup(4,3);');
handles.Points3text   = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Sounding ID:'               ,   'Position',[box_x+05 box_y+60  box_w box_h],'HorizontalAlignment','left');
handles.Points3       = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','2001'                       ,   'Position',[box_x+85 box_y+60  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','PointsSoundingID', 'callback','UCIT_DC_loadRelevantInfo2Popup(4,4);');
handles.Points4text   = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Data ID:'                   ,   'Position',[box_x+05 box_y+40  box_w box_h],'HorizontalAlignment','left');
handles.Points4       = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','ztide'                      ,   'Position',[box_x+85 box_y+40  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','PointsDataID');
handles.Points5text   = uicontrol(gcf,'UserData','UIControl','Style','text',     'String','Actions:'                   ,   'Position',[box_x+05 box_y+20  box_w box_h],'HorizontalAlignment','left');
handles.Points5       = uicontrol(gcf,'UserData','UIControl','Style','popupmenu','String','Select action ...'          ,   'Position',[box_x+85 box_y+20  box_w box_h],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','PtActions',        'callback','UCIT_DC_takeAction(4);');

SetUIBackgroundColors;

%% Load data

wb = waitbox('Initializing UCIT ...');

% reset all 4 popup values for both types (1: transects, 2: grids)
addpath('..\UCIT\UCIT_Guicode\')
UCIT_DC_resetValuesOnPopup(1,1,1,1,1,1)
UCIT_DC_resetValuesOnPopup(2,1,1,1,1,1)
UCIT_DC_resetValuesOnPopup(3,1,1,1,1,1)
UCIT_DC_resetValuesOnPopup(4,1,1,1,1,1)

drawnow

% % reset all 4 popup values for both types (1: transects, 2: grids)
% addpath('..\UCIT\UCIT_Guicode\')
% UCIT_DC_resetValuesOnPopup(1,1,1,1,1,1)
% UCIT_DC_resetValuesOnPopup(2,1,1,1,1,1)
% UCIT_DC_resetValuesOnPopup(3,1,1,1,1,1)
% UCIT_DC_resetValuesOnPopup(4,1,1,1,1,1)
%
% drawnow

disp('finding available transect data ...')
try
    UCIT_DC_loadRelevantInfo2Popup(1,1)
end

% set for proper type (1: transects, 2: grids) first popup menu: DataType
disp('finding available grid data ...')
try
    UCIT_DC_loadRelevantInfo2Popup(2,1)
end

% set for proper type (1: transects, 2: grids) first popup menu: DataType
disp('finding available line data ...')
try
    UCIT_DC_loadRelevantInfo2Popup(3,1)
end

% set for proper type (1: transects, 2: grids) first popup menu: DataType
disp('finding available point data ...')
try
    UCIT_DC_loadRelevantInfo2Popup(4,1)
end

close(wb);




