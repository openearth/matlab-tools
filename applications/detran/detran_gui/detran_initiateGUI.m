function h1 = detran_initiateGUI()
%DETRAN_INITIATEGUI Detran GUI function to generate the GUI window and all objects
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

h1 = figure('MenuBar','none','Name','DETRAN V2010a','Position',[100 100 1024 768],'Tag','figure1','numberTitle','off');

h2 = axes('Parent',h1,'Units','normalized','Position',[0.253 0.021 0.675 0.965],'Box','on','DataAspectRatioMode','manual',...
'FontSize',8,'Layer','top','PlotBoxAspectRatioMode','manual','Tag','axes1');

h7 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadData','Position',[0.01 0.92 0.1 0.03],'String','Load data','Tag','detran_loadDataBut');

h8 = uicontrol('Parent',h1,'Units','normalized','Position',[0.01 0.0065 0.1 0.03],'String','Layer 1','Style','popupmenu','Value',1,'Tag','detran_layerSelector');

h9 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_prepareTransPlot;detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.8 0.13 0.03],...
'String',{  'Total transport'; 'Bed load'; 'Suspended load' },'Style','popupmenu','Value',1,'Tag','detran_transType');

h10 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.75 0.13 0.03],...
'String',{  'Per second'; 'Per minute'; 'Hourly'; 'Daily'; 'Weekly'; 'Monthly'; 'Yearly'; 'User-defined (sec)' },...
'Style','popupmenu','Value',1,'Tag','detran_timeWindow');

h11 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.15 0.75 0.08 0.03],...
'String','1','Style','edit','TooltipString','Specify user-defined period in seconds','Tag','detran_specTimeWindow');

h12 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_prepareTransPlot;detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.7 0.13 0.03],...
'String','fraction1','Style','popupmenu','Value',1,'Tag','detran_fraction');

h13 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.22 0.13 0.03],'String','map vector scaling:','Style','text','Tag','text3');

h14 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.29 0.12 0.03],'String','map vector spacing:','Style','text','Tag','text4');

h15 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.29 0.08 0.03],'String','1','Style','edit',...
'TooltipString','Specify vector spacing values per domain, seperated by spaces','Tag','detran_vecSpacing');

h16 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.25 0.08 0.03],'String',{  'Uniform'; 'Distance' },...
'Style','popupmenu','Value',1,'Tag','detran_spaceMode');

h17 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.22 0.08 0.03],'String','1',...
'Style','edit','TooltipString','Specify vector scaling for map transport vectors','Tag','detran_vecScalingMap');

h18 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadTransects','Position',[0.01 0.60 0.10 0.03],'String','Load transects','Tag','detran_loadTransectsBut');

h19 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.01 0.47 0.14 0.03],'String','Plot map transport field','Style','checkbox','Tag','detran_plotMapBox');

h20 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.01 0.15 0.17 0.03],...
'String','Plot transport through transetcs','Style','checkbox','Tag','detran_plotTransectBox');

h21 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_saveTransects','Position',[0.13 0.60 0.10 0.03],'String','Save transects','Tag','detran_saveTransectsBut');

h22 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.01 0.12 0.17 0.03],'String','Plot gross transports','Style','checkbox','Tag','detran_plotGrossBox');

h23 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.39 0.13 0.03],'String','color scale:','Style','text','Tag','text6');

h24 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.39 0.08 0.03],'String','0 1','Style','edit',...
'TooltipString','Specify color scale of map plot, 2 values seperated by a space-character','Tag','detran_colScale');

h25 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_adjustTransect','Position',[0.01 0.56 0.10 0.03],'String','Adjust transect','Tag','detran_adjustTransectBut');

h26 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_export2lint','Position',[0.13 0.88 0.10 0.03],'String','Export to lintfile','Tag','detran_exportBut');

h27 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotLdb','Position',[0.01 0.43 0.12 0.03],'String','Plot landboundary','Style','checkbox','Tag','detran_plotLdbBox');

h28 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_addTransect','Position',[0.13 0.56 0.10 0.03],'String','Add transect','Tag','detran_addTransectBut');

h29 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.08 0.13 0.03],'String','transect vector scaling:','Style','text','Tag','text7');

h30 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.15 0.08 0.08 0.03],'String','1','Style','edit',...
'TooltipString','Specify vector scaling for transport vectors through transects','Tag','detran_vecScaling');

h31 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.05 0.13 0.03],'String','multiply transport labels by:','Style','text','Tag','text8');

h32 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.15 0.05 0.08 0.03],'String','1','Style','edit',...
'TooltipString','Sepcify factor (e.g. 0.001 to presents transport in thousands m^3)','Tag','detran_transLabelFactor');

h33 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_saveData','Position',[0.13 0.92 0.10 0.03],'String','Save data','Tag','detran_saveDataBut');

h34 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_importData','Position',[0.01 0.88 0.10 0.03],'String','Import data','Tag','detran_importDataBut');

h35 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.83 0.19 0.03],...
'String','Transport settings','Style','text','Tag','text9');

h36 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.51 0.19 0.03],...
'String','Map plot settings','Style','text','Tag','text10');

h37 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.19 0.19 0.03],...
'String','Transect vector plot settings','Style','text','Tag','text11');

h38 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.64 0.19 0.03],...
'String','Transect options','Style','text','Tag','text12');

h39 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.96 0.19 0.03],...
'String','Data input/output','Style','text','Tag','text14');

h40 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadLandboundary','Position',[0.13 0.43 0.10 0.03],'String','Load landboundary','Tag','detran_loadLdbBut');

h41 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.25 0.12 0.03],'String','spacing mode:','Style','text','Tag','text15');

h42 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_toggleColorbar','Position',[0.01 0.36 0.14 0.03],'String','Plot colorbar','Style','checkbox','Tag','detran_colorbarBox');

h43 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_exportFig','Position',[0.15 0.01 0.08 0.03],'String','Export2fig','Tag','detran_exportFigBut');

h44 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.68 0.15 0.02],...
'String','Inlcude a pore volume of:','Style','checkbox','Tag','detran_poreCheck');

h45 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','HorizontalAlignment','right','Position',[0.17 0.67 0.03 0.03],...
'String','40','Style','edit','TooltipString','Specify user-defined period in seconds','Tag','detran_poreWindow');

h46 = uicontrol('Parent',h1,'Units','normalized','Position',[0.21 0.67 0.02 0.02],'String','%','Style','text','Tag','text16');

h47   = uimenu('Parent',h1,'Label','File','Tag','detran_fileMenu');
h47_1 = uimenu('Parent',h47,'Label','Load data','Callback','detran_loadData');
h47_2 = uimenu('Parent',h47,'Label','Save data','Callback','detran_saveData');
h47_3 = uimenu('Parent',h47,'Label','Exit','Callback','close(gcf);');

h48   = uimenu('Parent',h1,'Label','Help','Tag','detran_helpMenu');
h48_1 = uimenu('Parent',h48,'Label','Online help','Callback','web(''www.openearth.nl'',''-browser'')');
h48_2 = uimenu('Parent',h48,'Label','About','Callback','detran_about');

data=detran_createEmptyStructure;
set(h1,'userdata',data);
set(h1,'Toolbar','figure');
set(findall(h1,'type','uipushtool'),'Separator','off');
set(findall(h1,'type','uitoggletool'),'Separator','off');
delete(findall(h1,'type','uipushtool'));
delete(findall(h1,'tag','figToolRotate3D'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeSelectToolBtn'));
delete(findall(h1,'tag','Annotation.InsertLegend'));
delete(findall(h1,'tag','Annotation.InsertColorbar'));
delete(findall(h1,'tag','Exploration.DataCursor'));
delete(findall(h1,'tag','Exploration.Rotate'));
delete(findall(h1,'tag','Standard.EditPlot'));
