function outh=gui_light(h)
%GUI_LIGHT displays a graphical user interface for a light object
%      GUI_LIGHT(TextHandle) to edit an existing light object
%      GUI_LIGHT to create a new light object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Light attributes', ...
               'Other attributes');
objtype='light';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : LIGHT ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

handles{2}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','style:',get(handle,'style'),[1 1]);
handles{2}(10:11)=gelm_color(fig,cmdname,0,2,visible,'on','color:',get(handle,'color'),[1 5]);

handles{2}(3:4)=gelm_edit(fig,cmdname,0,5,visible,'on','x:',index(get(handle,'position'),1),[1 2]);
handles{2}(5:6)=gelm_edit(fig,cmdname,0,6,visible,'on','y:',index(get(handle,'position'),2),[1 3]);
handles{2}(7:8)=gelm_edit(fig,cmdname,0,7,visible,'on','z:',index(get(handle,'position'),3),[1 4]);

handles{2}(9)=gelm_text1(fig,cmdname,0,4,visible,'on','position:');

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
