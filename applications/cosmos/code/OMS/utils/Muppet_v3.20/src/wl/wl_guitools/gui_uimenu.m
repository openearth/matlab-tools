function outh=gui_uimenu(h)
%GUI_UIMENU displays a graphical user interface for a uimenu object
%      GUI_UIMENU(UiMenuHandle) to edit an existing uimenu object
%      GUI_UIMENU to create a new uimenu object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Uimenu properties', ...
               'Children', ...
               'Other attributes');
objtype='uimenu';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------



% 1 : UIMENU PROPERTIES
visible=logicalswitch(default==1,'on','off');

handles{2}(1:2)=gelm_edit(fig,cmdname,0,1,visible,'on','label:',get(handle,'label'),[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','position:',get(handle,'position'),[1 2]);
handles{2}(5:6)=gelm_color(fig,cmdname,0,3,visible,'on','color:',get(handle,'foregroundcolor'),[1 3]);
handles{2}(7:8)=gelm_text2(fig,cmdname,0,4,visible,'on','enabled:',get(handle,'enable'),[1 4]);
handles{2}(9:10)=gelm_text2(fig,cmdname,0,5,visible,'on','checked:',get(handle,'checked'),[1 5]);
handles{2}(11:12)=gelm_text2(fig,cmdname,0,6,visible,'on','separator:',get(handle,'separator'),[1 6]);
handles{2}(13:14)=gelm_edit(fig,cmdname,0,7,visible,'on','accelerator:',get(handle,'accelerator'),[1 7]);

% 2 : CHILDREN
visible=logicalswitch(default==2,'on','off');
handles{3}(1)=gelm_pushbutton(fig,cmdname,0,1,visible,'on','refresh list',[2 1]);
[chld,names]=childlist(handle);
handles{3}(2)=gelm_list(fig,cmdname,0,6,5,0,visible,'on',names);
set(handles{3}(2),'userdata',chld);
handles{3}(3)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(isempty(chld),'off','on'),'open interface for child',[2 2]);
handles{3}(4)=gelm_pushbutton(fig,cmdname,0,8,visible,'on','create child',[2 3]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
