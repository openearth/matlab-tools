function H=blocks(tri,x,y,zmin,varargin)
%BLOCKS Plots blocks based on patches and z limits.
%   H = BLOCKS(TRI,X,Y,Z1,Z2)
%   plots 3D blocks using the base surfaces defined
%   by the index array TRI and location vectors X,Y.
%   TRI may contain triangles or indices for patches
%   with more corner points. The extent of the blocks
%   in vertical direction is given by the vectors
%   Z1 and Z2. Their length should equal the number
%   of locations (defined by X,Y) or the number of
%   base patches (defined by the rows of TRI). Z1 is
%   not necessarily smaller or larger than Z2. When
%   requested the function returns a vector H of patch
%   object handles.
%
%   H = BLOCKS(TRI,X,Y,Z1)
%   uses Z2=0.
%
%   BLOCKS(...,'cdata',C)
%   uses C as color instead of Z1/Z2.

% (c) 2002, H.R.A. Jagers
%           WL | Delft Hydraulics, The Netherlands
% Created: Nov. 27, 2002

x=x(:);
y=y(:);
ops=varargin;
if isempty(ops) | ischar(ops{1})
  zmax=zmin;
  zmin=0;
else
  zmax=ops{1};
  ops=ops(2:end);
end
if mod(length(ops),2)==1
   error('Invalid parameter/value pair arguments.')
end
i=1;
clr=[];
while i<length(ops)
   if ~ischar(ops{i}) | size(ops{i},1)>1 | ndims(ops{i})~=2
     error('Invalid parameter/value pair arguments.')
   end
   switch lower(ops{i})
   case 'cdata'
      clr=ops{i+1};
      ops(i:i+1)=[];
   otherwise
      i=i+2;
   end
end
zmax=zmax(:);
zmin=zmin(:);
if length(zmin)==1
  if length(zmax)~=1
    zmin=repmat(zmin,size(zmax));
  else
    zmin=repmat(zmin,size(x));
  end
end
if length(zmax)==1
  zmax=repmat(zmax,size(zmin));
end
if length(zmin)==length(x)
  % nothing to do ...
elseif length(zmin)==size(tri,1)
  % make nodes unique ...
  [b,i]=unique(tri);
  j=setdiff(1:prod(size(tri)),i);
  if ~isempty(j)
    idx=length(x)+(1:length(j));
    x(idx)=x(tri(j));
    y(idx)=y(tri(j));
    tri(j)=idx;
  end
  [dum,ii]=sort(tri(:));
  ii=mod(ii-1,size(tri,1))+1;
  zmin=zmin(ii);
  zmax=zmax(ii);
  if ~isempty(clr)
    clr=clr(ii,:);
  end
else
  error('Length of zmin vector does not match number of (x,y) points nor number of patches');
end

ax=gca;

usezasclr=0;
if isempty(clr)
   usezasclr=1;
end

P=zeros(1,3);
if usezasclr
   clr=zmin;
end
P(1) = patch('faces',tri,'vertices',[x y zmin],'facevertexcdata',clr,...
    'facecolor',get(ax,'defaultsurfacefacecolor'), ...
    'edgecolor',get(ax,'defaultsurfaceedgecolor'));
if usezasclr
   clr=zmax;
end
P(2) = patch('faces',tri,'vertices',[x y zmax],'facevertexcdata',clr,...
    'facecolor',get(ax,'defaultsurfacefacecolor'), ...
    'edgecolor',get(ax,'defaultsurfaceedgecolor'));
ix=[sort([1:size(tri,2) 2:size(tri,2)]) 1];
edges=tri(:,ix);
edges=reshape(edges',[2 prod(size(tri))])';
edges=sort(edges,2);
[tempedge,ii,jj]=unique(edges,'rows');
doubleocc=find(sparse(jj,1,1)>1);
jj(ismember(jj,doubleocc))=[];
edges=tempedge(jj,:);
edges=[edges fliplr(edges+length(x))];
if usezasclr
   clr=[zmin;zmax];
else
   clr=[clr;clr];
end
P(3) = patch('faces',edges,'vertices',[x y zmin;x y zmax],'facevertexcdata',clr,...
    'facecolor',get(ax,'defaultsurfacefacecolor'), ...
    'edgecolor',get(ax,'defaultsurfaceedgecolor'));

if nargout==1
  H=P;
end