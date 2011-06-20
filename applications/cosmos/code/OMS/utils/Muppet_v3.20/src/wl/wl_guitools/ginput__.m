function ginput__(cmd)

global GINPUT3D_ref_level
global GINPUT3D_ref_direc

fig=gcf;
l=get(fig,'userdata');
if ~isempty(l),
  ax=gca;
  xrange=get(ax,'xlim');
  yrange=get(ax,'ylim');
  zrange=get(ax,'zlim');

  pnt=get(ax,'currentpoint');
  if GINPUT3D_ref_direc==1,
    xref=GINPUT3D_ref_level;
        alpha=(xref-pnt(1,1))/(pnt(2,1)-pnt(1,1));
  elseif GINPUT3D_ref_direc==2,
       yref=GINPUT3D_ref_level;
        alpha=(yref-pnt(1,2))/(pnt(2,2)-pnt(1,2));
  elseif GINPUT3D_ref_direc==3,
       zref=GINPUT3D_ref_level;
        alpha=(zref-pnt(1,3))/(pnt(2,3)-pnt(1,3));
    end;
  pntref=pnt(1,:)+alpha*(pnt(2,:)-pnt(1,:));

  set(l(1),'xdata',pntref(1)*ones(1,5), ...
           'ydata',[yrange(1) yrange fliplr(yrange)], ...
           'zdata',[fliplr(zrange) zrange zrange(2)]);
  set(l(2),'xdata',[xrange(1) xrange fliplr(xrange)], ...
           'ydata',pntref(2)*ones(1,5), ...
           'zdata',[fliplr(zrange) zrange zrange(2)]);
  set(l(3),'xdata',[xrange(1) xrange fliplr(xrange)], ...
           'ydata',[yrange fliplr(yrange) yrange(1)], ...
           'zdata',[pntref(3)*ones(1,5)]);
  set(l(4),'xdata',[xrange NaN pntref(1)*ones(1,2) NaN pntref(1)*ones(1,2)], ...
           'ydata',[pntref(2)*ones(1,2) NaN yrange NaN pntref(2)*ones(1,2)], ...
           'zdata',[pntref(3)*ones(1,2) NaN pntref(3)*ones(1,2) NaN zrange]);
  set(fig,'name',gui_str(pntref));
end;