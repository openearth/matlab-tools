function grayscale(fig)
% GRAYSCALE Converts the figure into a grayscale figure.
%      GRAYSCALE(FigHandle)
%      Converts all colors in the figure to shades of gray.
%
%      See also: COLORFIX, IDXCOLORS

% (c) 2001 H.R.A. Jagers
%          WL | Delft Hydraulics, Delft, The Netherlands

if nargin==0
  fig=get(0,'currentfigure');
  if isempty(fig), return; end
end
axh=allchild(fig)';
c=get(fig,'color');
d=mean(c); set(fig,'color',d([1 1 1]))
cmap=get(fig,'colormap');
set(fig,'colormap',repmat(mean(cmap,2),[1 3]))
dmapmode=get(fig,'dithermapmode');
if isequal(dmapmode,'manual')
  dmap=get(fig,'dithermap');
  set(fig,'dithermap',repmat(mean(dmap,2),[1 3]))
end
for hax=axh,
  tp=get(hax,'type');
  switch tp,
  case {'axes'}
    % color, xcolor, ycolor, zcolor, ambientlightcolor, children
    c=get(hax,'color');
    if ~ischar(c)
      d=mean(c); set(hax,'color',d([1 1 1]))
    end
    c=get(hax,'xcolor');
    d=mean(c); set(hax,'xcolor',d([1 1 1]))
    c=get(hax,'ycolor');
    d=mean(c); set(hax,'ycolor',d([1 1 1]))
    c=get(hax,'zcolor');
    d=mean(c); set(hax,'zcolor',d([1 1 1]))
    c=get(hax,'ambientlightcolor');
    d=mean(c); set(hax,'ambientlightcolor',d([1 1 1]))
    obj=allchild(hax)';
    for h=obj,
      tp=get(h,'type');
      switch tp,
      case {'patch'}
        % facevertexcdata, facecolor, edgecolor, markeredgecolor, markerfacecolor
        cdat=get(h,'facevertexcdata');
        if size(cdat,2)~=1, % true color
          set(h,'cdata',repmat(mean(cdat,2),[1 3]));
        end;
        c=get(h,'facecolor');
        if ~ischar(c)
          d=mean(c); set(h,'facecolor',d([1 1 1]))
        end
        c=get(h,'edgecolor');
        if ~ischar(c)
          d=mean(c); set(h,'edgecolor',d([1 1 1]))
        end
        c=get(h,'markeredgecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markeredgecolor',d([1 1 1]))
        end
        c=get(h,'markerfacecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markerfacecolor',d([1 1 1]))
        end
      case 'surface',
        % cdata, facecolor, edgecolor, markeredgecolor, markerfacecolor
        cdat=get(h,'cdata');
        if ndims(cdat)==3, % true color
          set(h,'cdata',repmat(mean(cdat,3),[1 1 3]));
        end;
        c=get(h,'facecolor');
        if ~ischar(c)
          d=mean(c); set(h,'facecolor',d([1 1 1]))
        end
        c=get(h,'edgecolor');
        if ~ischar(c)
          d=mean(c); set(h,'edgecolor',d([1 1 1]))
        end
        c=get(h,'markeredgecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markeredgecolor',d([1 1 1]))
        end
        c=get(h,'markerfacecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markerfacecolor',d([1 1 1]))
        end
      case 'surface',
        % cdata, facecolor, edgecolor, markeredgecolor, markerfacecolor
        cdat=get(h,'cdata');
        if ndims(cdat)==3, % true color
          set(h,'cdata',repmat(mean(cdat,3),[1 1 3]));
        end;
      case 'light'
        % color
        c=get(h,'color');
        d=mean(c); set(h,'color',d([1 1 1]))
      case 'line'
        % color, markeredgecolor, markerfacecolor
        c=get(h,'color');
        d=mean(c); set(h,'color',d([1 1 1]))
        c=get(h,'markeredgecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markeredgecolor',d([1 1 1]))
        end
        c=get(h,'markerfacecolor');
        if ~ischar(c)
          d=mean(c); set(h,'markerfacecolor',d([1 1 1]))
        end
      case 'rectangle'
        % facecolor, edgecolor
        c=get(h,'facecolor');
        d=mean(c); set(h,'facecolor',d([1 1 1]))
        c=get(h,'edgecolor');
        d=mean(c); set(h,'edgecolor',d([1 1 1]))
      case 'text'
        % color
        c=get(h,'color');
        d=mean(c); set(h,'color',d([1 1 1]))
      end;
    end;
  case 'uicontrol'
    % foregroundcolor, backgroundcolor, cdata
    c=get(hax,'foregroundcolor');
    d=mean(c); set(hax,'foregroundcolor',d([1 1 1]))
    c=get(hax,'backgroundcolor');
    d=mean(c); set(hax,'backgroundcolor',d([1 1 1]))
    cdat=get(hax,'cdata');
    if ndims(cdat)==3, % true color
      set(hax,'cdata',repmat(mean(cdat,3),[1 1 3]));
    end;
  end;
end;