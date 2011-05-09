function md_axes(ax,cmd),
if nargin==2,
  md_cmd_axes(ax,cmd);
elseif nargin==1,
  md_gui_axes(ax);
else,
  if ~isempty(gcbo) & strcmp(get(gcbf,'selectiontype'),'alt'),
    md_gui_axes(gcbo);
  end;
end;

function md_gui_axes(ax),
axoptions=get(ax,'userdata');
if isfield(axoptions,'Type'),
  axtype=axoptions.Type;
else,
  axtype=type(axoptions.Object);
end;
cmds= ...
  {'axes interface'                         {'2DH','2DV','ZT','TIME'}              ; ...
   'gui_axes'                               {'2DH','3D','2DV','ZT','TIME','OBJECT','undefined','LEGEND','annotation layer'}        ; ...
   'add annotation item'                    {'annotation layer'}                   ; ...
   'edit'                                   {'legend','counter'}                                      ; ...
   'edit title'                             {'2DH','3D','2DV','ZT','TIME'}                  ; ...
   'edit x label'                           {'2DH','3D','2DV','ZT','TIME'}                  ; ...
   'edit y label'                           {'2DH','3D','2DV','ZT','TIME'}                  ; ...
   'edit z label'                           {'3D'}                                     ; ...
   'make 3D'                                {'2DH'}                           ; ...
   'move'                                   {'3D','2DH','2DV','ZT','TIME','OBJECT','undefined','LEGEND','legend','counter'}        ; ...
   'zoom'                                   {'ZT','2DH','2DV','TIME'}              ; ...
   'animate'                                {'2DH','3D','2DV','ZT','TIME','OBJECT','undefined','LEGEND','annotation layer'} };
labels=str2mat(cmds{:,1});
for pt=size(cmds,1):-1:1,
  enab(pt)=~isempty(strmatch(axtype,cmds{pt,2},'exact'));
end;
Possible=find(enab);
enab=enab(Possible);
labels=labels(Possible,:);
option=ui_select({1,'command'},labels,enab);
if option>size(labels,1),
  return;
end;
option=deblank(labels(option,:));

switch(option),
case 'axes interface',
case 'gui_axes',
  try, gc(ax); end;
  return;
case 'add annotation item',
  md_annotation(ax);
  return;
case 'change axes type',
  axoptions=get(ax,'userdata');
  labels=str2mat('2DH', ...
                 '3D', ...
                 'TIME', ...
                 '2DV');
  axtype=gui_select({1 'axes type'},labels);
  if axtype>size(labels,1),
    return;
  else,
    axoptions.Type=labels(axtype,:);
    set(ax,'userdata',axoptions);
  end;
  return;
case 'make 3D',
  axoptions=get(ax,'userdata');
  axoptions.Type='3D';
  set(ax,'userdata',axoptions);
  zlim=limits(ax,'zlim');
  zlim=zlim(2)-zlim(1);
  if zlim==0, zlim=1; end;
  xlim=min(limits(ax,'xlim'),limits(ax,'ylim'));
  xlim=xlim(2)-xlim(1);
  dar=[1 1 3*zlim/xlim];
  set(ax,'dataaspectratio',dar,'drawmode','normal');
  md_camera(ax);
  return;
case 'edit',
  edit(axoptions.Object);
  return;
case 'edit title',
  set(get(ax,'title'),'editing','on');
  return;
case 'edit x label',
  set(get(ax,'xlabel'),'editing','on');
  return;
case 'edit y label',
  set(get(ax,'ylabel'),'editing','on');
  return;
case 'edit z label',
  set(get(ax,'zlabel'),'editing','on');
  return;
case 'move',
  if isequal(axtype,'legend'),
    md_selectmoveresize_legend(ax);
  else,
    md_selectmoveresize(ax);
  end;
  return;
case 'zoom',
  fig=get(ax,'parent');
  set(fig,'handlevisibility','on');
  waitforbuttonpress
  if isequal(gcf,fig) & strcmp(get(fig,'selectiontype'),'normal'),
    p1=get(ax,'currentpoint');
    rbbox
    p2=get(ax,'currentpoint');
    p=[p1(1,1:2);p2(1,1:2)];
    if isequal(p(1,:),p(2,:)),
      xlim=get(ax,'xlim');
      ylim=get(ax,'ylim');
      xlim=xlim/2+mean(xlim)/2;
      ylim=ylim/2+mean(ylim)/2;
      set(ax,'xlim',xlim,'ylim',ylim);
    else,
      set(ax,'xlim',[min(p(:,1)) max(p(:,1))],'ylim',[min(p(:,2)) max(p(:,2))]);
    end;
  elseif isequal(gcf,fig),
    xlim=get(ax,'xlim');
    ylim=get(ax,'ylim');
    xlim=mean(xlim)+[xlim-mean(xlim)]*2;
    ylim=mean(ylim)+[ylim-mean(ylim)]*2;
    set(ax,'xlim',xlim,'ylim',ylim);
  end;
  set(fig,'handlevisibility','off');
  return;
case 'cancel',
  return;
case 'animate',
  md_animate(ax);
  return;
otherwise,
  uiwait(msgbox(['Unknown command ''',option,'''.'],'modal'));
  return;
end;

if isempty(ax),
  return;
end;

