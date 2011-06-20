function H=tricontour(tri,x,y,z,v,levels,color),
% TRICONTOUR Contour plot for triangulated data
%
%    TRICONTOUR(TRI,X,Y,Z,Levels) displays the contour plot based on
%    triangles defined in the M-by-3 face matrix TRI as a surface. A
%    row of TRI contains indexes into the X,Y, and Z vertex vectors
%    to define a single triangular face.
%
%    TRICONTOUR(TRI,X,Y,Z,V,Levels) displays the contour plot based on
%    triangles defined in the M-by-3 face matrix TRI as a surface. A
%    row of TRI contains indexes into the X,Y, and Z vertex vectors
%    to define a single triangular face. The contours are determined
%    by the values V and the Levels.
%
%    H = TRICONTOUR(...) a vector H of handles to LINE or PATCH objects,
%    one handle per line. TRICONTOUR is not compatible with CLABEL.
% 
%    The contours are normally colored based on the current colormap
%    and are drawn as PATCH objects. You can override this behavior
%    with the syntax CONTOUR(...,'LINESPEC') to draw the contours as
%    LINE objects with the color and linetype specified.
% 
%    Example:
%       x=rand(20); y=rand(20); z=rand(20); tri=delaunay(x,y);
%       tricontour(tri,x,y,z,.3:.1:1); colorbar
% 
%    See also CONTOUR, CONTOURF, TRICONTOURF

% Copyright (c) 1999-2000 by H.R.A. Jagers
%   University of Twente / Delft Hydraulics, The Netherlands

error(nargchk(5,7,nargin));
getdata=0;
if nargin==7,
  if strcmp(color,'getdata'),
    getdata=1;
    lin = '*';
    col = '*';
  else,
    [lin,col,mark,msg] = colstyle(color);
  end;
elseif nargin==6,
  if ischar(levels)
    color=levels;
    levels=v;
    v=z;
    z=[];
    if strcmp(color,'getdata'),
      getdata=1;
      lin = '*';
      col = '*';
    else,
      [lin,col,mark,msg] = colstyle(color);
    end;
  else
    lin = '';
    col = '';
  end
else,
  levels=v;
  v=z;
  z=[];
  lin = '';
  col = '';
end;

if ~getdata,
  newplot;
  if isempty(col) % no color spec was given
    colortab = get(gca,'colororder');
    ncol = size(colortab,1);
  end
end;

x=transpose(x(:));
y=transpose(y(:));
zdef=~isempty(z);
if zdef
  z=transpose(z(:));
end
v=transpose(v(:));

Patches=1:size(tri,1);
if getdata,
  H={};
else,
  H=[];
end;
NonEmptyLevel=zeros(size(levels));
for LevelNr=1:length(levels),
  level=levels(LevelNr);
  Nlarger=sum(v(tri)>level,2);
  Nsmaller=sum(v(tri)<level,2);
  NaN_tri=any(isnan(v(tri)),2);
  Nsmaller(NaN_tri)=3;
  Nlarger(NaN_tri)=0;
  CLIndex=1+4*Nlarger+Nsmaller;
  Cutslevel=[0 3 2 0 3 3 3 0 2 3 0 0 0 0 0];
  NLevel=sum(Cutslevel(CLIndex));
  XLevel=repmat(NaN,[NLevel 1]);
  YLevel=XLevel;
  if zdef
    ZLevel=XLevel;
  end
  LvlOffset=0;

  % patches with three equal
  % Patch=Patches(CLIndex==1);

  % patches with two equal
  Patch=Patches((CLIndex==2) | (CLIndex==5));
  if ~isempty(Patch),
    LvlIndex=LvlOffset+(1:3:(3*length(Patch)));
    LvlIndex=[LvlIndex;LvlIndex+1];
    Index=tri(Patch,:);
    [Dummy,Permutation]=sort(v(Index)==level,2);
    Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
    % first element has elevation different from level
    Index=Index(:,[2 3]);
    XPoint=transpose(x(Index));
    XLevel(LvlIndex(:))=XPoint(:);
    YPoint=transpose(y(Index));
    YLevel(LvlIndex(:))=YPoint(:);
    if zdef
      ZPoint=transpose(z(Index));
      ZLevel(LvlIndex(:))=ZPoint(:);
    end
    LvlOffset=LvlOffset+3*length(Patch);
  end;

  % patches with one equal, one larger and one smaller
  Patch=Patches(CLIndex==6);
  if ~isempty(Patch),
    LvlIndex=LvlOffset+(1:3:(3*length(Patch)));
    LvlIndex=[LvlIndex;LvlIndex+1];
    Index=tri(Patch,:);
    [Dummy,Permutation]=sort(v(Index),2);
    Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
    % second element has elevation equal to level
    VTemp=v(Index);
    Lambda=min(1,(level-VTemp(:,1))./(VTemp(:,3)-VTemp(:,1)));
    XPoint=transpose([transpose(x(Index(:,1)))+Lambda.*transpose(x(Index(:,3))-x(Index(:,1))) transpose(x(Index(:,2)))]);
    XLevel(LvlIndex(:))=XPoint(:);
    YPoint=transpose([transpose(y(Index(:,1)))+Lambda.*transpose(y(Index(:,3))-y(Index(:,1))) transpose(y(Index(:,2)))]);
    YLevel(LvlIndex(:))=YPoint(:);
    if zdef
      ZPoint=transpose([transpose(z(Index(:,1)))+Lambda.*transpose(z(Index(:,3))-z(Index(:,1))) transpose(z(Index(:,2)))]);
      ZLevel(LvlIndex(:))=ZPoint(:);
    end
    LvlOffset=LvlOffset+3*length(Patch);
  end;

  % patches with two larger and one smaller
  Patch=Patches(CLIndex==10);
  if ~isempty(Patch),
    LvlIndex=LvlOffset+(1:3:(3*length(Patch)));
    LvlIndex=[LvlIndex;LvlIndex+1];
    Index=tri(Patch,:);
    [Dummy,Permutation]=sort(v(Index)<level,2);
    Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
    % last element has elevation less than level
    VTemp=v(Index);
    Lambda=min(1,(level-VTemp(:,3)*ones(1,2))./(VTemp(:,[1 2])-VTemp(:,3)*ones(1,2)));
    XPoint=transpose(transpose(x(Index(:,3)))*ones(1,2)+Lambda.*(x(Index(:,[1 2]))-transpose(x(Index(:,3)))*ones(1,2)));
    XLevel(LvlIndex(:))=XPoint(:);
    YPoint=transpose(transpose(y(Index(:,3)))*ones(1,2)+Lambda.*(y(Index(:,[1 2]))-transpose(y(Index(:,3)))*ones(1,2)));
    YLevel(LvlIndex(:))=YPoint(:);
    if zdef
      ZPoint=transpose(transpose(z(Index(:,3)))*ones(1,2)+Lambda.*(z(Index(:,[1 2]))-transpose(z(Index(:,3)))*ones(1,2)));
      ZLevel(LvlIndex(:))=ZPoint(:);
    end
    LvlOffset=LvlOffset+3*length(Patch);
  end;

  % patches with two smaller and one larger
  Patch=Patches(CLIndex==7);
  if ~isempty(Patch),
    LvlIndex=LvlOffset+(1:3:(3*length(Patch)));
    LvlIndex=[LvlIndex;LvlIndex+1];
    Index=tri(Patch,:);
    [Dummy,Permutation]=sort(v(Index)>level,2);
    Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
    % last element has elevation larger than level
    VTemp=v(Index);
    Lambda=min(1,(level-VTemp(:,[1 2]))./(VTemp(:,3)*ones(1,2)-VTemp(:,[1 2])));
    XPoint=transpose(x(Index(:,[1 2]))+Lambda.*(transpose(x(Index(:,3)))*ones(1,2)-x(Index(:,[1 2]))));
    XLevel(LvlIndex(:))=XPoint(:);
    YPoint=transpose(y(Index(:,[1 2]))+Lambda.*(transpose(y(Index(:,3)))*ones(1,2)-y(Index(:,[1 2]))));
    YLevel(LvlIndex(:))=YPoint(:);
    if zdef
      ZPoint=transpose(z(Index(:,[1 2]))+Lambda.*(transpose(z(Index(:,3)))*ones(1,2)-z(Index(:,[1 2]))));
      ZLevel(LvlIndex(:))=ZPoint(:);
    end
    LvlOffset=LvlOffset+3*length(Patch);
  end;

  % patches with one equal and two larger or two smaller
  Patch=Patches((CLIndex==3) | (CLIndex==9));
  if ~isempty(Patch),
    LvlIndex=LvlOffset+(1:2:(2*length(Patch)));
    Index=tri(Patch,:);
    [Dummy,Permutation]=sort(v(Index)==level,2);
    Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
    % third element has elevation equal to level
    Index=Index(:,3);
    XPoint=x(Index);
    XLevel(LvlIndex(:))=XPoint(:);
    YPoint=y(Index);
    YLevel(LvlIndex(:))=YPoint(:);
    if zdef
      ZPoint=z(Index);
      ZLevel(LvlIndex(:))=ZPoint(:);
    end
    LvlOffset=LvlOffset+2*length(Patch);
  end;

  VLevel=level*ones(size(XLevel));

  if 1, %~isempty(XLevel),
    NonEmptyLevel(LevelNr)=1;
    if getdata,
      if zdef
        H{LevelNr}={XLevel YLevel ZLevel LevelNr};
      else
        H{LevelNr}={XLevel YLevel LevelNr};
      end
    elseif isempty(col) & isempty(lin),
      if ~zdef
        ZLevel=VLevel;
      end
      NewH = patch('XData',transpose([XLevel;XLevel]), ...
                   'YData',transpose([YLevel;YLevel]), ...
                   'ZData',transpose([ZLevel;ZLevel]), ...
                   'CData',transpose([VLevel;VLevel]), ... 
                   'facecolor','none', ...
                   'edgecolor','flat',...
                   'userdata',level);
      H=[H NewH];
    else,
      if ~zdef
        ZLevel=VLevel;
      end
      NewH = line('XData',XLevel,'YData',YLevel,'ZData',ZLevel,'userdata',level);
      H=[H NewH];
    end;
  end;
end;

levels=levels(logical(NonEmptyLevel));

if getdata,
  % do nothing
elseif isempty(col) & ~isempty(lin)
  nlvl = length(levels);
  colortab = colortab(mod(1:nlvl,ncol)+1,:);
  for i = 1:length(H)
    set(H(i),'linestyle',lin,'color',colortab(i,:));
  end
else
  if ~isempty(lin)
    set(H,'linestyle',lin);
  end
  if ~isempty(col)
    set(H,'color',col);
  end
end
