function md_selectmoveresize(ax),
% MD_SELECTMOVERESIZE Interactively select, move, resize or delete objects.
%    MD_SELECTMOVERESIZE as a button down function will handle
%    selecting, moving, resizing, and copying of Axes and Uicontrol 
%    graphics objects even if the object or figure has handle visibility
%    set to off.
%
%    differences compared to SELECTMOVERESIZE:
%      right click: unselect instead of copy
%      middle click (or double click): delete


if (nargin==1) | isempty(gcbf), % initialize
  if nargin==0,
    fig=get(0,'currentfigure');
    if isempty(fig),
      return;
    else,
      ax=get(fig,'currentaxes');
      if isempty(ax),
        return;
      end;
    end;
  end;
%  set(get(ax,'parent'),'handlevisibility','on');
%  Props={'parent','units','position','dataaspectratio','plotboxaspectratio','xlim','ylim','zlim'};
  Props={'parent','units','position'};
  PropVals=get(ax,Props);
  ax2=axes(Props,PropVals, ...
           'visible','on', ...
           'color','none', ...
           'box','on', ...
           'xtick',[], ...
           'ytick',[], ...
           'ztick',[], ...
           'xcolor',[.75 .75 .75], ...
           'ycolor',[.75 .75 .75], ...
           'zcolor',[.75 .75 .75], ...
           'parent',get(ax,'parent'), ...
           'userdata',ax);
  set(get(ax2,'xlabel'),'string','');
  set(get(ax2,'ylabel'),'string','');
  set(get(ax2,'zlabel'),'string','');
  set(ax2,'selected','on', ...
          'selectionhighlight','on', ...
          'buttondownfcn','md_selectmoveresize;');
else,
  switch get(gcbf,'selectiontype'),
  case 'normal',
    hvis=get(gcbf,'handlevisibility');
    set(gcbf,'handlevisibility','on');
    selectmoveresize;
    set(gcbf,'handlevisibility',hvis);
    Obs=findobj(gcbf,'buttondownfcn','md_selectmoveresize;','selected','on');
    for c=Obs',
      set(get(c,'userdata'),'position',get(c,'position'));
    end;
  case 'alt',
    set(gcbo,'selected','off');
  otherwise,
    delete(gcbo);
    set(gcbo,'selected','off','buttondownfcn','');
  end;
end;
