function outh=gui_text(h)
%GUI_TEXT displays a graphical user interface for a text object
%      GUI_TEXT(TextHandle) to edit an existing text object
%      GUI_TEXT to create a new text object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Text attributes', ...
               'Position attributes', ...
               'Other attributes');
objtype='text';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : TEXT ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

handles{2}([15 1 2])=gelm_text3(fig,cmdname,0,1,visible,'on','font','name:',get(handle,'fontname'),[1 1],[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','size:',get(handle,'fontsize'),[1 1],[1 2]);
handles{2}(5:6)=gelm_text2(fig,cmdname,0,4,visible,'on','weight:',get(handle,'fontweight'),[1 1]);
handles{2}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','angle:',get(handle,'fontangle'),[1 1]);

funittypes=str2mat('inches','centimeters','normalized','points','pixels');

handles{2}(11:12)=gelm_popupmenu(fig,cmdname,0,3,visible,'on','units:',funittypes,get(handle,'fontunits'),[1 4]);
handles{2}(9:10)=gelm_text2(fig,cmdname,0,7,visible,'on','interpreter:',get(handle,'interpreter'),[1 3]);

handles{2}(13)=gelm_text1(fig,cmdname,0,8,visible,'on','string:');
handles{2}(14)=gelm_ml_edit(fig,cmdname,0,10,2,visible,'on',get(handle,'string'),[1 5]);

handles{2}([16 17])=gelm_color(fig,cmdname,0,6,'on','on','color:',get(handle,'color'),[1 6]);

% 2 : POSITION ATTRIBUTES
visible=logicalswitch(default==2,'on','off');

handles{3}(1:2)=gelm_edit(fig,cmdname,4,2,visible,'on','x:',index(get(handle,'position'),1),[2 1]);
handles{3}(3:4)=gelm_edit(fig,cmdname,4,3,visible,'on','y:',index(get(handle,'position'),2),[2 2]);
handles{3}(5:6)=gelm_edit(fig,cmdname,4,4,visible,'on','z:',index(get(handle,'position'),3),[2 3]);
handles{3}(7)=gelm_pushbutton(fig,cmdname,1,1,visible,'on','new position',[2 4]);
handles{3}(8)=gelm_pushbutton(fig,cmdname,1,2,visible,'on','center x',[2 5]);
handles{3}(9)=gelm_pushbutton(fig,cmdname,1,3,visible,'on','center y',[2 6]);
handles{3}(10)=gelm_pushbutton(fig,cmdname,1,4,visible,'on','center z',[2 7]);

unittypes=str2mat('inches','centimeters','normalized','points','pixels','data');

handles{3}(11:12)=gelm_popupmenu(fig,cmdname,4,1,visible,'on','units:',unittypes,get(handle,'units'),[2 8]);
handles{3}(13:14)=gelm_edit(fig,cmdname,0,8,visible,'on','rotation:',get(handle,'rotation'),[2 9],[2 10]);

horaltypes=str2mat('left','center','right');

handles{3}(15:16)=gelm_popupmenu(fig,cmdname,0,6,visible,'on','horizontal alignment:',horaltypes,get(handle,'horizontalalignment'),[2 11]);

veraltypes=str2mat('top','cap','middle','baseline','bottom');

handles{3}(17:18)=gelm_popupmenu(fig,cmdname,0,7,visible,'on','vertical alignment:',veraltypes,get(handle,'verticalalignment'),[2 12]);

ermodtypes=str2mat('normal','background','xor','none');

handles{3}(19:20)=gelm_popupmenu(fig,cmdname,0,10,visible,'on','erasemode:',ermodtypes,get(handle,'erasemode'),[2 13]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on','userdata',handles);

if (nargout>0),
  outh=handle;
end;
