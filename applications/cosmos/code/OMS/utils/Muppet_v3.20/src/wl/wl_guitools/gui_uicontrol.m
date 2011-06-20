function outh=gui_uicontrol(h)
%GUI_UICONTROL displays a graphical user interface for a uicontrol object
%      GUI_UICONTROL(UiControlHandle) to edit an existing uicontrol object
%      GUI_UICONTROL to create a new uicontrol object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Font/string properties', ...
               'Coordinates', ...
               'Style properties', ...
               'Other attributes');
objtype='uicontrol';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------



% 1 : FONT/STRING PROPERTIES
visible=logicalswitch(default==1,'on','off');

handles{2}([15 1 2])=gelm_text3(fig,cmdname,0,1,visible,'on','font','name:',get(handle,'fontname'),[1 1],[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','size:',get(handle,'fontsize'),[1 1],[1 2]);
handles{2}(5:6)=gelm_text2(fig,cmdname,0,4,visible,'on','weight:',get(handle,'fontweight'),[1 1]);
handles{2}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','angle:',get(handle,'fontangle'),[1 1]);

funittypes=str2mat('inches','centimeters','normalized','points','pixels');

handles{2}(11:12)=gelm_popupmenu(fig,cmdname,0,3,visible,'on','units:',funittypes,get(handle,'fontunits'),[1 4]);

handles{2}(13)=gelm_text1(fig,cmdname,0,8,visible,'on','string:');
handles{2}(14)=gelm_ml_edit(fig,cmdname,0,10,2,visible,'on',get(handle,'string'),[1 5]);

horaltypes=str2mat('left','center','right');
handles{2}(18:19)=gelm_popupmenu(fig,cmdname,0,7,visible,'on','horizontal alignment:',horaltypes,get(handle,'horizontalalignment'),[1 7]);

handles{2}([16 17])=gelm_color(fig,cmdname,0,6,visible,'on','color:',get(handle,'foregroundcolor'),[1 6]);

% 2 : COORDINATES
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
handles{3}(10)=gelm_pushbutton(fig,cmdname,1,6,visible,'on','new lower left',[2 5]);

handles{3}(11)=line([55 240]-20,[vpos(2) vpos(4)],-50*ones(1,2), ...
   'color',[0 0 0], ...
   'linestyle','none', ...
   'marker','.', ...
   'markersize',20, ...
   'visible',visible, ...
   'parent',ax1);
handles{3}(12)=gelm_pushbutton(fig,cmdname,2,1,visible,'on','new upper right',[2 6]);

handles{3}(13)=gelm_pushbutton(fig,cmdname,2,6,visible,'on','both corners new',[2 7]);
handles{3}(14)=gelm_pushbutton(fig,cmdname,2,7,visible,'on','center left/right',[2 8]);
handles{3}(15)=gelm_pushbutton(fig,cmdname,2,8,visible,'on','center top/bottom',[2 9]);

unittypes=str2mat('inches','centimeters','normalized','points','pixels','characters');
handles{3}(16:17)=gelm_popupmenu(fig,cmdname,3,1,visible,'on','units:',unittypes,get(handle,'units'),[2 10]);


% 3 : STYLE PROPERTIES
visible=logicalswitch(default==3,'on','off');

styles=str2mat('pushbutton','radiobutton','checkbox','edit','text','slider','frame','listbox','popupmenu');
handles{4}(1:2)=gelm_popupmenu(fig,cmdname,0,1,visible,'on','style:',styles,get(handle,'style'),[3 1]);

handles{4}(3:4)=gelm_color(fig,cmdname,0,2,visible,'on','background color:',get(handle,'backgroundcolor'),[3 2]);

handles{4}(5:6)=gelm_edit(fig,cmdname,1,4,visible,'on','min:',get(handle,'min'),[3 3]);
handles{4}(7:8)=gelm_edit(fig,cmdname,2,4,visible,'on','max:',get(handle,'max'),[3 4]);

handles{4}(9:10)=gelm_edit(fig,cmdname,0,5,visible,'on','sliderstep min:',index(get(handle,'sliderstep'),1),[3 5]);
handles{4}(11:12)=gelm_edit(fig,cmdname,0,6,visible,'on','sliderstep max:',index(get(handle,'sliderstep'),2),[3 6]);

handles{4}(13:14)=gelm_edit(fig,cmdname,0,7,visible,'on','listboxtop:',get(handle,'listboxtop'),[3 7]);

handles{4}(15:16)=gelm_edit(fig,cmdname,0,8,visible,'on','value:',get(handle,'value'),[3 8]);

enabtypes=str2mat('on','inactive','off');
handles{4}(17:18)=gelm_popupmenu(fig,cmdname,0,9,visible,'on','enabled:',enabtypes,get(handle,'enable'),[3 9]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
