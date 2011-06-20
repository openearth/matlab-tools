function xx_setax(ax,Type),
axoptions=get(ax,'userdata');
if ~isfield(axoptions,'Type'),
  return;
elseif ~isequal(Type,'undefined') & ~isequal(axoptions.Type,'undefined'),
  return;
end;


switch Type,
case 'undefined',
  axoptions.Type='undefined';
  set(ax,'userdata',axoptions, ...
         'camerapositionmode','auto', ...
         'cameratargetmode','auto', ...
         'cameraupvectormode','auto', ...
         'cameraviewanglemode','auto', ...
         'projection','orthographic', ...
         'dataaspectratiomode','auto', ...
         'view',[0 90], ...
         'visible','on', ...
         'xlimmode','auto', ...
         'xtickmode','auto', ...
         'xticklabelmode','auto', ...
         'ylimmode','auto', ...
         'ytickmode','auto', ...
         'yticklabelmode','auto', ...
         'zlimmode','auto', ...
         'ztickmode','auto', ...
         'zticklabelmode','auto');
  set(get(ax,'xlabel'),'string','');
  set(get(ax,'ylabel'),'string','');
  set(get(ax,'zlabel'),'string','');
case '2DH',
  axoptions.Type='2DH';
  set(ax,'userdata',axoptions);
  set(ax,'dataaspectratio',[1 1 1]);
  set(get(ax,'xlabel'),'string','m');
  set(get(ax,'ylabel'),'string','m');
  set(ax,'xlimmode','auto','xtickmode','auto','xticklabelmode','auto');
  set(ax,'ylimmode','auto','ytickmode','auto','yticklabelmode','auto');
case '2DV',
  axoptions.Type='2DV';
  set(ax,'userdata',axoptions);
  set(ax,'dataaspectratiomode','auto');
  set(get(ax,'xlabel'),'string','m');
  set(get(ax,'ylabel'),'string','m');
  set(ax,'xlimmode','auto','xtickmode','auto','xticklabelmode','auto');
  set(ax,'ylimmode','auto','ytickmode','auto','yticklabelmode','auto');
case 'TN',
  axoptions.Type='TN';
  set(ax,'userdata',axoptions);
  set(ax,'dataaspectratiomode','auto');
  set(get(ax,'xlabel'),'string','time step');
  set(get(ax,'ylabel'),'string','time');
%  datetick(ax,'y');
  set(ax,'xlimmode','auto','xtickmode','auto','xticklabelmode','auto');
case 'ZT',
  axoptions.Type='ZT';
  set(ax,'userdata',axoptions);
  set(ax,'dataaspectratiomode','auto');
  set(get(ax,'xlabel'),'string','time');
  set(get(ax,'ylabel'),'string','m');
%  datetick(ax,'x');
  set(ax,'ylimmode','auto','ytickmode','auto','yticklabelmode','auto');
case 'XXX',
  axoptions.Type='XXX';
  set(ax,'userdata',axoptions);
end;