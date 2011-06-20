function outh=gui_image(h)
%GUI_IMAGE displays a graphical user interface for a image object
%      GUI_IMAGE(TextHandle) to edit an existing image object
%      GUI_IMAGE to create a new image object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Image attributes', ...
               'Other attributes');
objtype='image';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : IMAGE ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

% x limits
xdata=get(handle,'xdata');
xdata=[min(min(xdata)) max(max(xdata))];
set(handle,'xdata',xdata);

handles{2}(1:2)=gelm_edit(fig,cmdname,0,1,visible,'on','maximum x:',max(xdata),[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','minimum x:',min(xdata),[1 2]);

% y limits
ydata=get(handle,'ydata');
ydata=[min(min(ydata)) max(max(ydata))];
set(handle,'ydata',ydata);

handles{2}(5:6)=gelm_edit(fig,cmdname,0,3,visible,'on','maximum y:',max(ydata),[1 3]);
handles{2}(7:8)=gelm_edit(fig,cmdname,0,4,visible,'on','minimum y:',min(ydata),[1 4]);

handles{2}(9)=gelm_pushbutton(fig,cmdname,0,5,visible,'on','edit color data',[1 5]);
handles{2}(10:11)=gelm_text2(fig,cmdname,0,6,visible,'on','color data mapping:',get(handle,'cdatamapping'),[1 6]);

ermodtypes=str2mat('normal','background','xor','none');

handles{2}(12:13)=gelm_popupmenu(fig,cmdname,0,10,visible,'on','erasemode:',ermodtypes,get(handle,'erasemode'),[1 7]);


%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
