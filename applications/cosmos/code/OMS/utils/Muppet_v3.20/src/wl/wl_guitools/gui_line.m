function outh=gui_line(h)
%GUI_LINE displays a graphical user interface for a line object
%      GUI_LINE(TextHandle) to edit an existing line object
%      GUI_LINE to create a new line object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Line attributes', ...
               'Other attributes');
objtype='line';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : LINE ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

lsttypes=str2mat('-','--',':','-.','none');

handles{2}(1:2)=gelm_popupmenu(fig,cmdname,0,1,visible,'on','line style:',lsttypes,get(handle,'linestyle'),[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','line width:',get(handle,'linewidth'),[1 2]);

msttypes=str2mat('+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none');

handles{2}(11:12)=gelm_popupmenu(fig,cmdname,0,4,visible,'on','marker:',msttypes,get(handle,'marker'),[1 7]);
handles{2}(5:6)=gelm_edit(fig,cmdname,0,5,visible,'on','marker size:',get(handle,'markersize'),[1 3]);

coltyp=str2mat('none','auto','colorspec');

handles{2}(13:16)=gelm_popupcolor(fig,ax1,cmdname,0,6,visible,'on','marker edge color:',coltyp,get(handle,'markeredgecolor'),[1 8]);
handles{2}(17:20)=gelm_popupcolor(fig,ax1,cmdname,0,7,visible,'on','marker face color:',coltyp,get(handle,'markerfacecolor'),[1 9]);

handles{2}(7)=gelm_pushbutton(fig,cmdname,1,8,visible,'on','new data',[1 4]);
handles{2}(8)=gelm_pushbutton(fig,cmdname,2,8,visible,'on','edit data',[1 5]);

ermodtypes=str2mat('normal','background','xor','none');
handles{2}(9:10)=gelm_popupmenu(fig,cmdname,0,9,visible,'on','erase mode:',ermodtypes,get(handle,'erasemode'),[1 6]);
handles{2}(21:22)=gelm_color(fig,cmdname,0,3,visible,'on','line color:',get(handle,'color'),[1 10]);


%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on','userdata',handles);

if (nargout>0),
  outh=handle;
end;
