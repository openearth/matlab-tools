function outh=gui_surface(h)
%GUI_SURFACE displays a graphical user interface for a patch object
%      GUI_SURFACE(TextHandle) to edit an existing surface object
%      GUI_SURFACE to create a new surface object

%      Copyright (c) H.R.A. Jagers  12-17-1996

frames=str2mat('Surface attributes', ...
               'Lines and markers', ...
               'Lighting', ...
               'Normals', ...
               'Other attributes');
objtype='surface';
handle=[];
if nargin==0, h=[]; end
[notfinished,handle,handles,default,fig,cmdname,ax1]=gui_general(objtype,h,frames);
if notfinished, return; end;
%------------------------------------------------------------------------------------------

% 1 : SURFACE ATTRIBUTES
visible=logicalswitch(default==1,'on','off');

coltypes=str2mat('none','flat','interp','texturemap','colorspec');

handles{2}(1:4)=gelm_popupcolor(fig,ax1,cmdname,0,1,visible,'on','face color:',coltypes,get(handle,'facecolor'),[1 1]);

coltypes=str2mat('none','flat','interp','colorspec');

handles{2}(5:8)=gelm_popupcolor(fig,ax1,cmdname,0,2,visible,'on','edge color:',coltypes,get(handle,'edgecolor'),[1 3]);

handles{2}(11)=gelm_pushbutton(fig,cmdname,1,4,visible,'on','new data',[1 6]);
handles{2}(12)=gelm_pushbutton(fig,cmdname,2,4,visible,'on','edit data',[1 7]);

handles{2}(13:14)=gelm_text2(fig,cmdname,0,7,visible,'on','cdata mapping:',get(handle,'cdatamapping'),[1 8]);

ermodtypes=str2mat('normal','background','xor','none');

handles{2}(15:16)=gelm_popupmenu(fig,cmdname,0,8,visible,'on','erasemode:',ermodtypes,get(handle,'erasemode'),[1 9]);

msttypes=str2mat('both','column','row');

handles{2}(17:18)=gelm_popupmenu(fig,cmdname,0,3,visible,'on','meshstyle:',msttypes,get(handle,'meshstyle'),[1 10]);

% 2 : LINE ATTRIBUTES
visible=logicalswitch(default==2,'on','off');

lsttypes=str2mat('-','--',':','-.','none');

handles{3}(1:2)=gelm_popupmenu(fig,cmdname,0,1,visible,'on','line style:',lsttypes,get(handle,'linestyle'),[2 1]);
handles{3}(3:4)=gelm_edit(fig,cmdname,0,2,visible,'on','line width:',get(handle,'linewidth'),[2 2]);

msttypes=str2mat('+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none');

handles{3}(11:12)=gelm_popupmenu(fig,cmdname,0,4,visible,'on','marker:',msttypes,get(handle,'marker'),[2 7]);
handles{3}(5:6)=gelm_edit(fig,cmdname,0,5,visible,'on','marker size:',get(handle,'markersize'),[2 3]);

coltyp=str2mat('none','auto','colorspec');

handles{3}(13:16)=gelm_popupcolor(fig,ax1,cmdname,0,6,visible,'on','marker edge color:',coltyp,get(handle,'markeredgecolor'),[2 8]);
handles{3}(17:20)=gelm_popupcolor(fig,ax1,cmdname,0,7,visible,'on','marker face color:',coltyp,get(handle,'markerfacecolor'),[2 9]);


% 3 : LIGHTING
visible=logicalswitch(default==3,'on','off');

lghtypes=str2mat('none','flat','gouraud','phong');

handles{4}(1:2)=gelm_popupmenu(fig,cmdname,0,1,visible,'on','face lighting:',lghtypes,get(handle,'facelighting'),[3 1]);
handles{4}(3:4)=gelm_popupmenu(fig,cmdname,0,2,visible,'on','edge lighting:',lghtypes,get(handle,'edgelighting'),[3 2]);

bfltypes=str2mat('unlit','lit','reverselit');

handles{4}(5:6)=gelm_popupmenu(fig,cmdname,0,3,visible,'on','backface lighting:',bfltypes,get(handle,'backfacelighting'),[3 3]);
handles{4}(7:8)=gelm_edit(fig,cmdname,0,4,visible,'on','ambient strength:',get(handle,'ambientstrength'),[3 4]);
handles{4}(9:10)=gelm_edit(fig,cmdname,0,5,visible,'on','diffuse strength:',get(handle,'diffusestrength'),[3 5]);
handles{4}(11:12)=gelm_edit(fig,cmdname,0,6,visible,'on','specular strength:',get(handle,'specularstrength'),[3 6]);
handles{4}(13:14)=gelm_edit(fig,cmdname,0,7,visible,'on','specular exponent:',get(handle,'specularexponent'),[3 7]);
handles{4}(15:16)=gelm_edit(fig,cmdname,0,8,visible,'on','spec. color reflectance:',get(handle,'specularcolorreflectance'),[3 8]);


% 4 : NORMALS
visible=logicalswitch(default==4,'on','off');

handles{5}(1:2)=gelm_text2(fig,cmdname,0,1,visible,'on','normal mode:',get(handle,'normalmode'),[4 1]);
handles{5}(3)=gelm_pushbutton(fig,cmdname,2,2,visible,logicalswitch(strcmp(get(handle,'normalmode'),'auto'),'off','on'),'edit vertex normals',[4 2]);

%------------------------------------------------------------------------------------------
%make window visible
set(fig,'visible','on')

if (nargout>0),
  outh=handle;
end;

set(fig,'userdata',handles);
