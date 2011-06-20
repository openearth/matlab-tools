function idxcolors(fig)
% IDXCOLORS Converts to indexed colors.
%      IDXCOLOR(FigHandle)
%      Extends the colormap of the figure to include the
%      colors of all true color shaded objects in the figure.
%      Converts true color shaded and scaled value colored
%      objects into indexed colored objects.
%
%      Note:  Interpolation between adjacent surface points
%             may change due to the conversion from
%             true color to indexed color shading.
%
%      See also: COLORFIX

% (c) 2001 H.R.A. Jagers
%               WL | Delft Hydraulics, Delft, The Netherlands

if nargin==0
  fig=get(0,'currentfigure');
  if isempty(fig), return; end
end
haxes=findobj(fig,'type','axes');
climmode=get(haxes,'climmode');
set(haxes,'climmode','manual'); % keep axes from changing the climits during the conversion
hpatch=findobj(fig,'type','patch');
hsurf=findobj(fig,'type','surface');
himage=findobj(fig,'type','image');
hobj=[hpatch;hsurf;himage]';
cmap=get(fig,'colormap');
ncmap=cmap;
for h=hobj,
  tp=get(h,'type');
  switch tp,
  case {'patch'}
    cdat=get(h,'facevertexcdata');
    if size(cdat,2)==1,
      scal=get(h,'cdatamapping');
      if strcmp(scal,'scaled'),
        clim=get(get(h,'parent'),'clim');
        lcm=size(cmap,1);
        cdat=round(1+(lcm-1)*(min(clim(2),cdat)-clim(1))/(clim(2)-clim(1)));
        cdat=max(min(cdat,lcm),1);
        set(h,'facevertexcdata',cdat,'cdatamapping','direct');
      end;
    else % true color
      [clrs,dummy,idx]=unique(cdat,'rows');
      lcm=size(ncmap,1);
      ncmap=cat(1,ncmap,clrs);
      set(h,'facevertexcdata',lcm+idx,'cdatamapping','direct');
    end;
  case {'surface','image'}
    cdat=get(h,'cdata');
    if ndims(cdat)<3,
      scal=get(h,'cdatamapping');
      if strcmp(scal,'scaled'),
        clim=get(get(h,'parent'),'clim');
        lcm=size(cmap,1);
        cdat=round(1+(lcm-1)*(min(clim(2),cdat)-clim(1))/(clim(2)-clim(1)));
        cdat=max(min(cdat,lcm),1);
        set(h,'cdata',cdat,'cdatamapping','direct');
      end;
    else % true color
      szdat=size(cdat);
      cdat=reshape(cdat,[prod(szdat)/3 3]);
      [clrs,dummy,idx]=unique(cdat,'rows');
      lcm=size(ncmap,1);
      ncmap=cat(1,ncmap,clrs);
      idx=reshape(idx,szdat);
      set(h,'facevertexcdata',lcm+idx,'cdatamapping','direct');
    end;
  end;
end;
% compact cmap ...
[ncmap,dummy,remap]=unique(ncmap,'rows');
for h=hobj,
  tp=get(h,'type');
  switch tp,
  case {'patch'}
    cdat=get(h,'facevertexcdata');
    set(h,'facevertexcdata',remap(cdat));
  case {'surface','image'}
    cdat=get(h,'cdata');
    set(h,'cdata',remap(cdat));
  end;
end;
set(fig,'colormap',ncmap)
% Reset climmodes (actually, they probably do not matter anymore)
if iscell(climmode)
  for i=1:length(haxes)
    set(haxes(i),'climmode',climmode{i})
  end
else
  set(haxes,'climmode',climmode)
end
