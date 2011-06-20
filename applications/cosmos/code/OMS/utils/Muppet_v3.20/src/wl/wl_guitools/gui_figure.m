function outh=gui_figure(h)
%GUI_FIGURE displays a graphical user interface for an figure object
%      GUI_FIGURE(AxesHandle) to edit an existing figure object
%      GUI_FIGURE to create a new axes object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('General attributes', ...
               'Screen coordinates', ...
               'Paper coordinates', ...
               'Plot attributes', ...
               'Colors', ...
               'Children', ...
               'Other attributes');
objtype='figure';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : GENERAL ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

handles{2}(3:4)=gelm_text2(fig,cmdname,0,1,visible,'on','backing store:',get(handle,'backingstore'),[1 2]);
handles{2}(5:6)=gelm_text2(fig,cmdname,0,2,visible,'on','invert hardcopy:',get(handle,'inverthardcopy'),[1 3]);
handles{2}(17:18)=gelm_text2(fig,cmdname,0,3,visible,'on','renderer mode:',get(handle,'renderermode'),[1 10]);
handles{2}(19:20)=gelm_text2(fig,cmdname,0,4,visible,logicalswitch(strcmp(get(handle,'renderermode'),'manual'),'on','off'),'renderer:',get(handle,'renderer'),[1 11]);

handles{2}(1:2)=gelm_text2(fig,cmdname,0,5,visible,'on','integer handle:',get(handle,'integerhandle'),[1 1]);
handles{2}(7:8)=gelm_text2(fig,cmdname,0,6,visible,'on','number title:',get(handle,'numbertitle'),[1 4]);
handles{2}(9:10)=gelm_edit(fig,cmdname,0,7,visible,'on','name:',get(handle,'name'),[1 5]);
handles{2}(11:12)=gelm_text2(fig,cmdname,0,8,visible,'on','menu bar:',get(handle,'menubar'),[1 6]);

pointertypes=str2mat('crosshair','fullcrosshair','arrow','ibeam','watch','topl','topr','botl','botr','left','top','right','bottom','circle','cross','fleur','custom');

handles{2}(13:14)=gelm_popupmenu(fig,cmdname,0,9,visible,'on','pointer:',pointertypes,get(handle,'pointer'),[1 7]);

cp=strcmp(get(handle,'pointer'),'custom');
handles{2}(15)=gelm_pushbutton(fig,cmdname,1,10,visible,logicalswitch(cp,'on','off'),'edit custom shape',[1 8]);
handles{2}(16)=gelm_pushbutton(fig,cmdname,2,10,visible,logicalswitch(cp,'on','off'),'edit hot spot',[1 9]);

% 2 : SCREEN COORDINATES
visible=logicalswitch(default==2,'on','off');

handles{3}(1:2)=gelm_edit(fig,cmdname,3,7,visible,'on','x:',index(get(handle,'position'),1),[2 1]);
handles{3}(3:4)=gelm_edit(fig,cmdname,3,8,visible,'on','y:',index(get(handle,'position'),2),[2 2]);

handles{3}(5:6)=gelm_edit(fig,cmdname,8,3,visible,'on','width:',index(get(handle,'position'),3),[2 3]);
handles{3}(7:8)=gelm_edit(fig,cmdname,8,4,visible,'on','height:',index(get(handle,'position'),4),[2 4]);

vpos=gelm_vpos(5,3);
vpos(2)=vpos(2)+vpos(4)/6;
vpos(4)=vpos(2)+vpos(4);
handles{3}(9)=line([55 55 240 240 55]-20,[vpos(2) vpos(4) vpos(4) vpos(2) vpos(2)],-50*ones(1,5), ...
   'color',[0 0 0], ...
   'visible',visible, ...
   'parent',ax1);

handles{3}(11)=line([55 240]-20,[vpos(2) vpos(4)],-50*ones(1,2), ...
   'color',[0 0 0], ...
   'linestyle','none', ...
   'marker','.', ...
   'markersize',20, ...
   'visible',visible, ...
   'parent',ax1);

handles{3}(14)=gelm_pushbutton(fig,cmdname,2,7,visible,'on','center left/right',[2 8]);
handles{3}(15)=gelm_pushbutton(fig,cmdname,2,8,visible,'on','center top/bottom',[2 9]);

unittypes=str2mat('inches','centimeters','normalized','points','pixels');

handles{3}(16:17)=gelm_popupmenu(fig,cmdname,3,1,visible,'on','units:',unittypes,get(handle,'units'),[2 10]);

% 3 : PAPER COORDINATES
ppmauto=strcmp(get(handle,'paperpositionmode'),'auto');
visible=logicalswitch(default==3,'on','off');

handles{4}(1:2)=gelm_edit(fig,cmdname,3,7,visible,logicalswitch(ppmauto,'off','on'),'x:',index(get(handle,'paperposition'),1),[3 1]);
handles{4}(3:4)=gelm_edit(fig,cmdname,3,8,visible,logicalswitch(ppmauto,'off','on'),'y:',index(get(handle,'paperposition'),2),[3 2]);

handles{4}(5:6)=gelm_edit(fig,cmdname,8,4,visible,logicalswitch(ppmauto,'off','on'),'width:',index(get(handle,'paperposition'),3),[3 3]);
handles{4}(7:8)=gelm_edit(fig,cmdname,8,5,visible,logicalswitch(ppmauto,'off','on'),'height:',index(get(handle,'paperposition'),4),[3 4]);

vpos=gelm_vpos(6,3);
vpos(2)=vpos(2)+vpos(4)/6;
vpos(4)=vpos(2)+vpos(4);
handles{4}(9)=line([55 55 240 240 55]-20,[vpos(2) vpos(4) vpos(4) vpos(2) vpos(2)],-50*ones(1,5), ...
   'color',[0 0 0], ...
   'visible',visible, ...
   'parent',ax1);

handles{4}(11)=line([55 240]-20,[vpos(2) vpos(4)],-50*ones(1,2), ...
   'color',[0 0 0], ...
   'linestyle','none', ...
   'marker','.', ...
   'markersize',20, ...
   'visible',visible, ...
   'parent',ax1);

handles{4}(12:13)=gelm_text2(fig,cmdname,0,2,visible,'on','position mode:',get(handle,'paperpositionmode'),[3 11]);

handles{4}(14)=gelm_pushbutton(fig,cmdname,2,7,visible,'on','center left/right',[3 8]);
handles{4}(15)=gelm_pushbutton(fig,cmdname,2,8,visible,'on','center top/bottom',[3 9]);

unittypes=str2mat('inches','centimeters','normalized','points');

handles{4}(16:17)=gelm_popupmenu(fig,cmdname,3,1,visible,'on','units:',unittypes,get(handle,'paperunits'),[3 10]);

pttypes=str2mat('usletter','uslegal','a3','a4letter','a5','b4','tabloid');

handles{4}(18:19)=gelm_popupmenu(fig,cmdname,0,9,visible,'on','paper type:',pttypes,get(handle,'papertype'),[3 12]);
handles{4}(20:21)=gelm_text2(fig,cmdname,0,10,visible,'on','paper orientation:',get(handle,'paperorientation'),[3 13]);

% 4 : PLOT AREA PROPERTIES
visible=logicalswitch(default==4,'on','off');

plotstyles=str2mat('add','replace','replacechildren');

handles{5}(1:2)=gelm_popupmenu(fig,cmdname,0,1,visible,'on','next plot:',plotstyles,get(handle,'nextplot'),[4 1]);


handles{5}(3:4)=gelm_text2(fig,cmdname,0,3,visible,'on','resize:',get(handle,'resize'),[4 2]);
handles{5}(5)=gelm_pushbutton(fig,cmdname,0,4,visible,get(handle,'resize'),'edit resize function',[4 3]);

handles{5}(6)=gelm_pushbutton(fig,cmdname,0,5,visible,'on','edit close request function',[4 4]);
handles{5}(7)=gelm_pushbutton(fig,cmdname,0,6,visible,'on','edit key press function',[4 5]);

%handles{5}(8:9)=gelm_lockpushbutton(fig,cmdname,0,7,visible,'on','accept and make modal',[4 6],[4 7]);
handles{5}(10)=gelm_pushbutton(fig,cmdname,0,8,visible,'on','edit WindowButtonDown function',[4 8]);
handles{5}(11)=gelm_pushbutton(fig,cmdname,0,9,visible,'on','edit WindowButtonMotion function',[4 9]);
handles{5}(12)=gelm_pushbutton(fig,cmdname,0,10,visible,'on','edit WindowButtonUp function',[4 10]);


% 5 : COLORS
dmmauto=strcmp(get(handle,'dithermapmode'),'auto');
visible=logicalswitch(default==5,'on','off');

handles{6}(1:2)=gelm_color(fig,cmdname,0,1,visible,'on','color:',get(handle,'color'),[5 1]);

handles{6}(3)=gelm_pushbutton(fig,cmdname,0,3,visible,'on','edit colormap',[5 2]);

handles{6}(4:5)=gelm_text2(fig,cmdname,0,5,visible,'on','dither map mode:',get(handle,'dithermapmode'),[5 3]);
handles{6}(6)=gelm_pushbutton(fig,cmdname,0,6,visible,logicalswitch(dmmauto,'off','on'),'edit dither map',[5 4]);

handles{6}(7:8)=gelm_text2(fig,cmdname,0,8,visible,'on','share colors:',get(handle,'sharecolors'),[5 5]);
handles{6}(9:10)=gelm_edit(fig,cmdname,0,2,visible,'on','minimum colormap:',get(handle,'mincolormap'),[5 6]);

% 6 : CHILDREN
visible=logicalswitch(default==6,'on','off');
handles{7}(1)=gelm_pushbutton(fig,cmdname,0,1,visible,'on','refresh list',[6 1]);
[chld,names]=childlist(handle);
handles{7}(2)=gelm_list(fig,cmdname,0,5,4,0,visible,'on',names);
set(handles{7}(2),'userdata',chld);
handles{7}(3)=gelm_pushbutton(fig,cmdname,0,6,visible,logicalswitch(isempty(chld),'off','on'),'open interface for child',[6 2]);
handles{7}(7)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(isempty(chld),'off','on'),'put child on top',[6 6]);
handles{7}(4)=gelm_pushbutton(fig,cmdname,0,8,visible,'on','create axes',[6 3]);
handles{7}(5)=gelm_pushbutton(fig,cmdname,0,9,visible,'on','create uimenu',[6 4]);
handles{7}(6)=gelm_pushbutton(fig,cmdname,0,10,visible,'on','create uicontrol',[6 5]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
