function rgb2map(Fig,cmap)
%RGB2MAP Converts RGB colors to colormap indices.
%      RGB data cannot be plotted in Painter's mode.
%      This function can be used to remap RGB values
%      onto a fixed colormap.
%
%      RGB2MAP(FigureHandle,ColorMap)
%      The default color map is the current color map
%      of the selected figure. The default figure is
%      the current figure.
%
%      Remarks:
%      (1)  Interpolation between adjacent surface
%           pointsmay change due to the conversion
%           from true color to indexed shading.
%      (2)  This function will also affect objects
%           currently subject to scaled indexed if
%           the specified color map does not match
%           the current color map.

% (c) 2002, H.R.A. Jagers, hrajagers@hotmail.com
%           WL | Delft Hydraulics, Delft, The Netherlands

if nargin<1
  Fig=gcf;
elseif (nargin==1) & ~isequal(size(Fig),[1 1])
  cmap=Fig;
  Fig=gcf;
elseif nargin<2
  cmap=get(Fig,'colormap');
end

Obj=findall(Fig)';
if ~isequal(cmap,get(Fig,'colormap'))
  colorfix
end
for o=Obj
  switch get(o,'type')
  case {'surface','image'}
    cData=get(o,'cdata');
    if size(cData,3)==3
      [IndexImage,ColorMap]=rgb2idx(cData);
      remap=zeros(size(ColorMap,1),1);
      for i=1:size(ColorMap,1)
        [em,remap(i)]=min(sum((repmat(ColorMap(i,:),size(cmap,1),1)-cmap).^2,2));
      end
      set(o,'cdata',remap(IndexImage),'cdatamapping','direct')
    end
  case 'patch'
    cData=get(o,'FaceVertexCData');
    if size(cData,2)==3
      cData=reshape(cData,size(cData,1),1,3);
      [IndexImage,ColorMap]=rgb2idx(cData);
      remap=zeros(size(ColorMap,1),1);
      for i=1:size(ColorMap,1)
        [em,remap(i)]=min(sum((repmat(ColorMap(i,:),size(cmap,1),1)-cmap).^2,2));
      end
      set(o,'FaceVertexCData',remap(IndexImage),'cdatamapping','direct')
    end
  end
end
set(Fig,'colormap',cmap)
