function outh=gui_axes(h)
%GUI_AXES displays a graphical user interface for an axes object
%      GUI_AXES(AxesHandle) to edit an existing axes object
%      GUI_AXES to create a new axes object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Tick attributes', ...
               'Plot area coordinates', ...
               'View attributes', ...
               'Plot area attributes', ...
               'Color palette', ...
               'X axes properties', ...
               'X limits / ticks', ...
               'Y axes properties', ...
               'Y limits / ticks', ...
               'Z axes properties', ...
               'Z limits / ticks', ...
               'Camera attributes', ...
               'Children', ...
               'Other attributes');
objtype='axes';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

three_dim=(~all(get(handle,'view')==[0 90]));


% 1 : TICK PROPERTIES
tdauto=strcmp(get(handle,'tickdirmode'),'auto');
visible=logicalswitch(default==1,'on','off');

handles{2}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','font name:',get(handle,'fontname'),[1 1]);
handles{2}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','size:',get(handle,'fontsize'),[1 1],[1 2]);
handles{2}(5:6)=gelm_text2(fig,cmdname,0,4,visible,'on','weight:',get(handle,'fontweight'),[1 1]);
handles{2}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','angle:',get(handle,'fontangle'),[1 1]);

funittypes=str2mat('inches','centimeters','normalized','points','pixels');

handles{2}(15:16)=gelm_popupmenu(fig,cmdname,0,3,visible,'on','units:',funittypes,get(handle,'fontunits'),[1 6]);

handles{2}(9:10)=gelm_text2(fig,cmdname,0,7,visible,logicalswitch(tdauto,'off','on'),'tickdirection:',get(handle,'tickdir'),[1 3]);
handles{2}(11:12)=gelm_edit(fig,cmdname,0,8,visible,'on','tick length:',index(get(handle,'ticklength'),1+three_dim),[1 4]);
set(handles{2}(12),'userdata',three_dim);
handles{2}(13:14)=gelm_text2(fig,cmdname,0,6,visible,'on','tickdirmode:',get(handle,'tickdirmode'),[1 5]);

% 2 : PLOT AREA COORDINATES
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

unittypes=str2mat('inches','centimeters','normalized','points','pixels');

handles{3}(16:17)=gelm_popupmenu(fig,cmdname,3,1,visible,'on','units:',unittypes,get(handle,'units'),[2 10]);

% 3 : VIEW / DATAASPECTRATIO
darauto=strcmp(get(handle,'dataaspectratiomode'),'auto');
pbarauto=strcmp(get(handle,'plotboxaspectratiomode'),'auto');
visible=logicalswitch(default==3,'on','off');

handles{4}(1:2)=gelm_edit(fig,cmdname,6,1,visible,'on','azimuth:',index(get(handle,'view'),1),[3 1]);
handles{4}(3:4)=gelm_edit(fig,cmdname,6,2,visible,'on','elevation:',index(get(handle,'view'),2),[3 2]);
handles{4}(5)=gelm_pushbutton(fig,cmdname,0,4,visible,'on','edit XForm',[3 3]);
handles{4}(6)=gelm_text1(fig,cmdname,4,1.5,visible,logicalswitch(three_dim,'off','on'),logicalswitch(three_dim,'3D','2D'));

handles{4}(7:8)=gelm_edit(fig,cmdname,3,7,visible,logicalswitch(darauto,'off','on'),'x:',index(get(handle,'dataaspectratio'),1),[3 4]);
handles{4}(9:10)=gelm_edit(fig,cmdname,3,8,visible,logicalswitch(darauto,'off','on'),'y:',index(get(handle,'dataaspectratio'),2),[3 5]);
handles{4}(11:12)=gelm_edit(fig,cmdname,3,9,visible,logicalswitch(darauto,'off','on'),'z:',index(get(handle,'dataaspectratio'),3),[3 6]);
handles{4}(13)=gelm_text1(fig,cmdname,1,5,visible,'on','data aspect ratio:');
handles{4}(14:15)=gelm_text2(fig,cmdname,3,6,visible,'on','mode:',get(handle,'dataaspectratiomode'),[3 7]);

handles{4}(16:17)=gelm_edit(fig,cmdname,4,7,visible,logicalswitch(pbarauto,'off','on'),'x:',index(get(handle,'plotboxaspectratio'),1),[3 8]);
handles{4}(18:19)=gelm_edit(fig,cmdname,4,8,visible,logicalswitch(pbarauto,'off','on'),'y:',index(get(handle,'plotboxaspectratio'),2),[3 9]);
handles{4}(20:21)=gelm_edit(fig,cmdname,4,9,visible,logicalswitch(pbarauto,'off','on'),'z:',index(get(handle,'plotboxaspectratio'),3),[3 10]);
handles{4}(22)=gelm_text1(fig,cmdname,2,5,visible,'on','plotbox aspect ratio:');
handles{4}(23:24)=gelm_text2(fig,cmdname,4,6,visible,'on','mode:',get(handle,'plotboxaspectratiomode'),[3 11]);

handles{4}(25:26)=gelm_text2(fig,cmdname,0,3,visible,'on','projection:',get(handle,'projection'),[3 12]);


% 4 : PLOT AREA PROPERTIES
visible=logicalswitch(default==4,'on','off');

handles{5}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','box:',get(handle,'box'),[4 1]);
handles{5}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','line width:',get(handle,'linewidth'),[4 2]);
handles{5}(5:6)=gelm_text2(fig,cmdname,0,3,visible,'on','layer:',get(handle,'layer'),[4 3]);
handles{5}(7:8)=gelm_text2(fig,cmdname,0,4,visible,'on','drawmode:',get(handle,'drawmode'),[4 4]);

plotstyles=str2mat('add','replace','replacechildren');

handles{5}(9:10)=gelm_popupmenu(fig,cmdname,0,5,visible,'on','next plot:',plotstyles,get(handle,'nextplot'),[4 5]);

gridstyles=str2mat('-','--',':','-.');

handles{5}(15:16)=gelm_popupmenu(fig,cmdname,0,7,visible,'on','grid style:',gridstyles,get(handle,'gridlinestyle'),[4 8]);
handles{5}(17:18)=gelm_popupmenu(fig,cmdname,0,8,visible,'on','minor grid style:',gridstyles,get(handle,'minorgridlinestyle'),[4 9]);
colstyles=str2mat('none','colorspec');
handles{5}(19:22)=gelm_popupcolor(fig,ax1,cmdname,0,9,visible,'on','color',colstyles,get(handle,'color'),[4 10]);


% 5 : COLOR PALETTE
climauto=strcmp(get(handle,'climmode'),'auto');
visible=logicalswitch(default==5,'on','off');

handles{6}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','color limits mode:',get(handle,'climmode'),[5 1]);
handles{6}(3:4)=gelm_edit(fig,cmdname,0,3,visible,logicalswitch(climauto,'off','on'),'minimum:',index(get(handle,'clim'),1),[5 2]);
handles{6}(5:6)=gelm_edit(fig,cmdname,0,2,visible,logicalswitch(climauto,'off','on'),'maximum:',index(get(handle,'clim'),2),[5 3]);

handles{6}(7)=gelm_pushbutton(fig,cmdname,0,5,visible,'on','edit color order',[5 4]);

handles{6}(8:9)=gelm_color(fig,cmdname,0,7,visible,'on','ambient light color:',get(handle,'ambientlightcolor'),[5 5]);


% 6 : X AXES PROPERTIES
scalelog=strcmp(get(handle,'xscale'),'log');
visible=logicalswitch(default==6,'on','off');

handles{7}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','grid:',get(handle,'xgrid'),[6 1]);
handles{7}(3:4)=gelm_text2(fig,cmdname,0,2,visible,logicalswitch(scalelog,'off','on'),'minor grid:',get(handle,'xminorgrid'),[6 2]);
handles{7}(5:6)=gelm_text2(fig,cmdname,0,3,visible,logicalswitch(scalelog,'off','on'),'minor ticks:',get(handle,'xminortick'),[6 3]);

handles{7}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','direction:',get(handle,'xdir'),[6 4]);
handles{7}(9:10)=gelm_text2(fig,cmdname,0,6,visible,'on','scale:',get(handle,'xscale'),[6 5]);
handles{7}(11:12)=gelm_text2(fig,cmdname,0,7,visible,'on','location:',get(handle,'xaxislocation'),[6 6]);

handles{7}(13:14)=gelm_color(fig,cmdname,0,9,visible,'on','color:',get(handle,'xcolor'),[6 7]);


% 7 : X LIMITS / TICKS
limauto=strcmp(get(handle,'xlimmode'),'auto');
tickauto=strcmp(get(handle,'xtickmode'),'auto');
labelauto=strcmp(get(handle,'xticklabelmode'),'auto');
visible=logicalswitch(default==7,'on','off');
if (default==7) & tickauto & (~labelauto),
  set(handle,'xticklabelmode','auto');
end;

handles{8}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','limits mode:',get(handle,'xlimmode'),[7 1]);
handles{8}(3:4)=gelm_edit(fig,cmdname,0,3,visible,logicalswitch(limauto,'off','on'),'minimum:',index(get(handle,'xlim'),1),[7 2]);
handles{8}(5:6)=gelm_edit(fig,cmdname,0,2,visible,logicalswitch(limauto,'off','on'),'maximum:',index(get(handle,'xlim'),2),[7 3]);

handles{8}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','tick mode:',get(handle,'xtickmode'),[7 4]);
handles{8}(9)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(tickauto,'off','on'),'new ticks',[7 5]);
handles{8}(10)=gelm_pushbutton(fig,cmdname,0,8,visible,logicalswitch(tickauto,'off','on'),'edit ticks',[7 6]);
handles{8}(11:12)=gelm_text2(fig,cmdname,0,6,visible,logicalswitch(tickauto,'off','on'),'tick label mode:',get(handle,'xticklabelmode'),[7 7]);

% 8 : Y AXES PROPERTIES
scalelog=strcmp(get(handle,'yscale'),'log');
visible=logicalswitch(default==8,'on','off');

handles{9}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','grid:',get(handle,'ygrid'),[8 1]);
handles{9}(3:4)=gelm_text2(fig,cmdname,0,2,visible,logicalswitch(scalelog,'off','on'),'minor grid:',get(handle,'yminorgrid'),[8 2]);
handles{9}(5:6)=gelm_text2(fig,cmdname,0,3,visible,logicalswitch(scalelog,'off','on'),'minor ticks:',get(handle,'yminortick'),[8 3]);

handles{9}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','direction:',get(handle,'ydir'),[8 4]);
handles{9}(9:10)=gelm_text2(fig,cmdname,0,6,visible,'on','scale:',get(handle,'yscale'),[8 5]);
handles{9}(11:12)=gelm_text2(fig,cmdname,0,7,visible,'on','location:',get(handle,'yaxislocation'),[8 6]);

handles{9}(13:14)=gelm_color(fig,cmdname,0,9,visible,'on','color:',get(handle,'ycolor'),[8 7]);

% 9 : Y LIMITS / TICKS
limauto=strcmp(get(handle,'ylimmode'),'auto');
tickauto=strcmp(get(handle,'ytickmode'),'auto');
labelauto=strcmp(get(handle,'yticklabelmode'),'auto');
visible=logicalswitch(default==9,'on','off');
if (default==9) & tickauto & (~labelauto),
  set(handle,'yticklabelmode','auto');
  labelauto=1;
end;

handles{10}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','limits mode:',get(handle,'ylimmode'),[9 1]);
handles{10}(3:4)=gelm_edit(fig,cmdname,0,3,visible,logicalswitch(limauto,'off','on'),'minimum:',index(get(handle,'ylim'),1),[9 2]);
handles{10}(5:6)=gelm_edit(fig,cmdname,0,2,visible,logicalswitch(limauto,'off','on'),'maximum:',index(get(handle,'ylim'),2),[9 3]);

handles{10}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','tick mode:',get(handle,'ytickmode'),[9 4]);
handles{10}(9)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(tickauto,'off','on'),'new ticks',[9 5]);
handles{10}(10)=gelm_pushbutton(fig,cmdname,0,8,visible,logicalswitch(tickauto,'off','on'),'edit ticks',[9 6]);
handles{10}(11:12)=gelm_text2(fig,cmdname,0,6,visible,logicalswitch(tickauto,'off','on'),'tick label mode:',get(handle,'yticklabelmode'),[9 7]);

% 10 : Z AXES PROPERTIES
scalelog=strcmp(get(handle,'zscale'),'log');
visible=logicalswitch(default==10,'on','off');

handles{11}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','grid:',get(handle,'zgrid'),[10 1]);
handles{11}(3:4)=gelm_text2(fig,cmdname,0,2,visible,logicalswitch(scalelog,'off','on'),'minor grid:',get(handle,'zminorgrid'),[10 2]);
handles{11}(5:6)=gelm_text2(fig,cmdname,0,3,visible,logicalswitch(scalelog,'off','on'),'minor ticks:',get(handle,'zminortick'),[10 3]);

handles{11}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','direction:',get(handle,'zdir'),[10 4]);
handles{11}(9:10)=gelm_text2(fig,cmdname,0,6,visible,'on','scale:',get(handle,'zscale'),[10 5]);

handles{11}(13:14)=gelm_color(fig,cmdname,0,9,visible,'on','color:',get(handle,'zcolor'),[10 7]);

% 11 : Z LIMITS / TICKS
limauto=strcmp(get(handle,'zlimmode'),'auto');
tickauto=strcmp(get(handle,'ztickmode'),'auto');
labelauto=strcmp(get(handle,'zticklabelmode'),'auto');
visible=logicalswitch(default==11,'on','off');
if (default==11) & tickauto & (~labelauto),
  set(handle,'zticklabelmode','auto');
  labelauto=1;
end;

handles{12}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','limits mode:',get(handle,'zlimmode'),[11 1]);
handles{12}(3:4)=gelm_edit(fig,cmdname,0,3,visible,logicalswitch(limauto,'off','on'),'minimum:',index(get(handle,'zlim'),1),[11 2]);
handles{12}(5:6)=gelm_edit(fig,cmdname,0,2,visible,logicalswitch(limauto,'off','on'),'maximum:',index(get(handle,'zlim'),2),[11 3]);

handles{12}(7:8)=gelm_text2(fig,cmdname,0,5,visible,'on','tick mode:',get(handle,'ztickmode'),[11 4]);
handles{12}(9)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(tickauto,'off','on'),'new ticks',[11 5]);
handles{12}(10)=gelm_pushbutton(fig,cmdname,0,8,visible,logicalswitch(tickauto,'off','on'),'edit ticks',[11 6]);
handles{12}(11:12)=gelm_text2(fig,cmdname,0,6,visible,logicalswitch(tickauto,'off','on'),'tick label mode:',get(handle,'zticklabelmode'),[11 7]);

% 12 : CAMERA ATTRIBUTES
cvaauto=strcmp(get(handle,'cameraviewanglemode'),'auto');
cuvauto=strcmp(get(handle,'cameraupvectormode'),'auto');
cpauto=strcmp(get(handle,'camerapositionmode'),'auto');
ctauto=strcmp(get(handle,'cameratargetmode'),'auto');
visible=logicalswitch(default==12,'on','off');

handles{13}(1:2)=gelm_text2(fig,cmdname,1,1,visible,'on','up vector:',get(handle,'cameraupvectormode'),[12 1]);
handles{13}(3:4)=gelm_edit(fig,cmdname,3,2,visible,logicalswitch(cuvauto,'off','on'),'x:',index(get(handle,'cameraupvector'),1),[12 2]);
handles{13}(5:6)=gelm_edit(fig,cmdname,3,3,visible,logicalswitch(cuvauto,'off','on'),'y:',index(get(handle,'cameraupvector'),2),[12 3]);
handles{13}(7:8)=gelm_edit(fig,cmdname,3,4,visible,logicalswitch(cuvauto,'off','on'),'z:',index(get(handle,'cameraupvector'),3),[12 4]);

handles{13}(9:10)=gelm_text2(fig,cmdname,2,1,visible,'on','position:',get(handle,'camerapositionmode'),[12 5]);
handles{13}(11:12)=gelm_edit(fig,cmdname,4,2,visible,logicalswitch(cpauto,'off','on'),'x:',index(get(handle,'cameraposition'),1),[12 6]);
handles{13}(13:14)=gelm_edit(fig,cmdname,4,3,visible,logicalswitch(cpauto,'off','on'),'y:',index(get(handle,'cameraposition'),2),[12 7]);
handles{13}(15:16)=gelm_edit(fig,cmdname,4,4,visible,logicalswitch(cpauto,'off','on'),'z:',index(get(handle,'cameraposition'),3),[12 8]);

handles{13}(17:18)=gelm_text2(fig,cmdname,1,6,visible,'on','target:',get(handle,'cameratargetmode'),[12 9]);
handles{13}(19:20)=gelm_edit(fig,cmdname,3,7,visible,logicalswitch(ctauto,'off','on'),'x:',index(get(handle,'cameratarget'),1),[12 10]);
handles{13}(21:22)=gelm_edit(fig,cmdname,3,8,visible,logicalswitch(ctauto,'off','on'),'y:',index(get(handle,'cameratarget'),2),[12 11]);
handles{13}(23:24)=gelm_edit(fig,cmdname,3,9,visible,logicalswitch(ctauto,'off','on'),'z:',index(get(handle,'cameratarget'),3),[12 12]);

handles{13}(25:26)=gelm_text2(fig,cmdname,2,6,visible,'on','angle:',get(handle,'cameraviewanglemode'),[12 13]);
handles{13}(27:28)=gelm_edit(fig,cmdname,4,7,visible,logicalswitch(cvaauto,'off','on'),'angle:',get(handle,'cameraviewangle'),[12 14]);

% 13 : CHILDREN
handles{14}(1)=gelm_pushbutton(fig,cmdname,0,1,visible,'on','refresh list',[13 1]);
[chld,names]=childlist(handle);
handles{14}(2)=gelm_list(fig,cmdname,0,5,4,0,visible,'on',names);
set(handles{14}(2),'userdata',chld);
handles{14}(3)=gelm_pushbutton(fig,cmdname,0,6,visible,logicalswitch(isempty(chld),'off','on'),'open interface for child',[13 2]);
handles{14}(10)=gelm_pushbutton(fig,cmdname,0,7,visible,logicalswitch(isempty(chld),'off','on'),'put child on top',[13 9]);
handles{14}(4)=gelm_pushbutton(fig,cmdname,1,8,visible,'on','create line',[13 3]);
handles{14}(5)=gelm_pushbutton(fig,cmdname,2,8,visible,'on','create text',[13 4]);
handles{14}(6)=gelm_pushbutton(fig,cmdname,1,9,visible,'on','create surface',[13 5]);
handles{14}(7)=gelm_pushbutton(fig,cmdname,2,9,visible,'on','create patch',[13 6]);
handles{14}(8)=gelm_pushbutton(fig,cmdname,1,10,visible,'on','create image',[13 7]);
handles{14}(9)=gelm_pushbutton(fig,cmdname,2,10,visible,'on','create light',[13 8]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
