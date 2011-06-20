function [notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames)
%GUI_GENERAL deals with the general part of the edit window
%      uses objtype for 'figure','axes','line',' etc.

%      Copyright (c) H.R.A. Jagers  12-17-1996

notfinished=1;
existed=~isempty(h);

if isempty(h),
  switch objtype,
  case 'figure',
    h=figure;
  case 'axes',
    h=axes;
  case 'image',
    h=image;
  case 'patch',
    h=patch';
  case 'surface',
    h=surface;
  case 'line',
    h=line;
  case 'text',
    h=text;
  case 'light',
    h=light;
  case 'uimenu',
    h=uimenu;
  case 'uicontrol',
    h=uicontrol;
  otherwise
    % this works if function is not compiled ...
    h=feval(objtype);
  end
end;

if isstr(h),
  hexhandle=h;
  handle=hex2num(hexhandle);
else,
  handle=h;
  hexhandle=num2hex(handle);
end;

if ~ishandle(handle),
  fprintf(1,['* Input argument must be a ',objtype,' handle\n']);
  return;
else,
  if ~strcmp(get(handle,'type'),objtype),
    fprintf(1,['* Input argument must be a ',objtype,' handle\n']);
    return;
  end;
end;

cmdname=['cmd_',objtype];

% set(handle,'buttondownfcn',['gui_',objtype,'(''',hexhandle,''')']);

%create window only if necessary
[fig,exists]=guix(handle);
if exists,
  return;
end;

%set up window if necessary
%Hfig=num2hex(fig);
Hfig=['hex2num(''',num2hex(fig),''')'];
bgc=[195 195 195]/255;
dgr=[128 128 128]/255;
col_edit=[1 1 1];
col_text=bgc;
set(fig,'units','pixels', ...
        'color',bgc, ...
        'inverthardcopy','off', ...
        'resize','off', ...
        'numbertitle','off', ...
        'name',[objtype,' - ',hexhandle])
pos=get(fig,'position');
vpos=gelm_vpos(0,1);
height=vpos(2)+vpos(4)+10;
hpos=gelm_hpos(10,0);
width=hpos(1)+hpos(3)+10;
%width=240;
%height=336;
pos(1)=max(0,pos(1)-(width-pos(3))/2);
pos(2)=max(0,pos(2)-(height-pos(4))/2);
pos(3)=width;
pos(4)=height;
set(fig,'position',pos);

callbackstr='';

handles={};


%figure filling axes
ax1=axes( ...
   'units','normalized','position',[0 0 1 1], ...
   'xlim',[1 width],'ylim',[1 height], ...
   'visible','off', ...
   'parent',fig);
vpos=gelm_vpos(12,1);
vpos=vpos(2)+vpos(4)+10;
horzline3d(0,vpos,width,'parent',ax1);

% backup object for cancel
switch(objtype),
case 'figure',
  ax_BackUp=copyprop(handle,0);
case {'axes','uicontrol','uimenu'},
  ax_BackUp=copyprop(handle,fig);
otherwise,
  ax_BackUp=copyprop(handle,ax1);
end;

set(ax_BackUp,'visible','off');

%reference to figure filling axes and example object
handles{1}(1:2)=[ax1 ax_BackUp];

%fossil button stopping gui_main, STILL USED FOR REMEMBERING THE HANDLE IN THE USERDATA !
handles{1}(3)=uicontrol( ...
   'units','pixels','position',[width-10 height-10 10 10], ...
   'string',' ', ...
   'visible','off', ...
   'userdata',handle, ...
   'callback',[cmdname,'(',Hfig,',[0 0])'], ...
   'parent',fig);

default=1;

%frames

handles{1}(4)=gelm_popupmenu1(fig,cmdname,0,0,'on','on',frames,frames(default,:),[0 1]);
set(handles{1}(4),'userdata',default);

handles{1}(5)=gelm_pushbutton(fig,cmdname,1,15,'on','on','accept changes',[0 2]);
handles{1}(6)=gelm_pushbutton(fig,cmdname,2,15,'on','on','cancel changes',[0 3]);
set(handles{1}(6),'userdata',existed);

%handles{1}(7:8)=gelm_text2(fig,cmdname,6,12,'on','on','editable:','on',[0 4]);
handles{1}(9:10)=gelm_text2(fig,cmdname,5,12,'on','on','visible:',get(handle,'visible'),[0 5]);

handles{1}(11:12)=gelm_lockpushbutton(fig,cmdname,2,14,'on','on','delete object',[0 6],[0 7]);

hvistypes=str2mat('on','callback','off');
handles{1}(17:18)=gelm_popupmenu(fig,cmdname,0,13,'on','on','handle visible:',hvistypes,get(handle,'handlevisibility'),[0 8]);

% last frame : OTHER ATTRIBUTES
nframes=size(frames,1);

visible=logicalswitch(default==nframes,'on','off');

handles{nframes+1}(1)=gelm_pushbutton(fig,cmdname,1,1,visible,'on','edit ButtonDownFcn',[nframes 1]);
handles{nframes+1}(2)=gelm_pushbutton(fig,cmdname,1,2,visible,'on','edit CreateFcn',[nframes 2]);
handles{nframes+1}(3)=gelm_pushbutton(fig,cmdname,1,3,visible,'on','edit DeleteFcn',[nframes 3]);

handles{nframes+1}(4:5)=gelm_text2(fig,cmdname,0,4,visible,'on','selected:',get(handle,'selected'),[nframes 4]);
handles{nframes+1}(6:7)=gelm_text2(fig,cmdname,0,5,visible,'on','highlight when selected:',get(handle,'selectionhighlight'),[nframes 5]);
handles{nframes+1}(8)=gelm_pushbutton(fig,cmdname,2,2,visible,'on','edit tag',[nframes 6]);
handles{nframes+1}(9)=gelm_pushbutton(fig,cmdname,2,3,visible,'on','edit user data',[nframes 7]);

handles{nframes+1}(14:15)=gelm_text2(fig,cmdname,0,6,visible,'on','interrruptible:',get(handle,'interruptible'),[nframes 10]);
handles{nframes+1}(10:11)=gelm_text2(fig,cmdname,0,7,visible,'on','action when busy:',get(handle,'busyaction'),[nframes 8]);
handles{nframes+1}(12:13)=gelm_text2(fig,cmdname,0,10,visible,'on','clipping:',get(handle,'clipping'),[nframes 9]);

if strcmp(objtype,'uicontrol') | strcmp(objtype,'uimenu'),
  handles{nframes+1}(16)=gelm_pushbutton(fig,cmdname,2,1,visible,'on','edit Callback',[nframes 11]);
end;

if ~strcmp(objtype,'figure'),
  handles{nframes+1}(17:18)=gelm_pushbutton(fig,cmdname,0,9,visible,'on','open interface for parent',[nframes 12]);
end;

notfinished=0;
