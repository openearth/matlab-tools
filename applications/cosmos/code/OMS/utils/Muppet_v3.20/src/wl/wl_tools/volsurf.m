function varargout=volsurf(varargin),
%VOLSURF compute triangulated surface of volume
%    [TRI1,X1,Y1,Z1,D1_1,D2_1,....]= ...
%        VOLSURF(X0,Y0,Z0,...
%                   D1_0,CondStr1,V1, ...
%                   D2_0,CondStr2,V2, ... )
%    TRI1,X1,Y1,Z1 is the triangulated surface of the volume
%    specified by X0,Y0,Z0 constrained by the specified condi-
%    tions. Each constraining condition consists of a dataset
%    (values specified at X0,Y0,Z0 positions) followed by one or
%    more combinations of a condition string ('below' or 'above')
%    and a threshold value.
%
%    H=VOLSURF(...,'color',CDATA)
%    Plots the surface and returns the handles. The surface is
%    colored using the specified CDATA (same size as X0, Y0, and Z0.
%
%    H=VOLSURF(...,capopt1,capopt2,...)
%    where capoptN can be one of: 'xmin','xmax','ymin','ymax',
%    'zmin','zmax','all','none' to plot only caps on the specified
%    surfaces. Default 'all'. 'all' overrules 'none', 'none'
%    overrules any surface explicitely specified.
%
%    See also: ISOSURF, ISOSURFACE, ISOCOLORS, ISOCAPS, TRICONSTRAIN

%    (c) copyright July 2000, H.R.A. Jagers, bert.jagers@wldelft.nl
%                   WL | Delft Hydraulics, Delft, The Netherlands
%                   http://www.wldelft.nl

if nargin<3,
  error('Not enough input arguments');
end;

X0=varargin{1};
Y0=varargin{2};
Z0=varargin{3};
C0=[];
Constr=cell(0,3);
c=0;

plotit=1;
if nargout>1,
  plotit=0;
  NPropsOut=nargout;
else,
  NPropsOut=4;
end;
whichcaps={};

i=4;
while i<=nargin,
  D=varargin{i};
  if ischar(D),
    switch lower(D),
    case 'color',
      if ~plotit,
        error('Color option not allowed when not plotting.');
      end;
      if nargin>i,
        i=i+1;
        C0=varargin{i};
        if ~isequal(size(C0),size(X0)),
          error(sprintf('Unexpected size of color dataset (argument %i).',i));
        end;
      else,
        error('Missing color dataset.');
      end;
    case {'xmin','xmax','ymin','ymax','zmin','zmax','all','none'},
      whichcaps{end+1}=lower(D);
    otherwise,
      error(sprintf('Unknown option string %s (argument %i).',D,i));
    end;
  elseif ~isequal(size(D),size(X0)),
    error(sprintf('Unexpected size of data argument %i.',i));
  else,
    c=c+1;
    Constr(c,1:3)={D,NaN,NaN};
    while nargin>i,
      Str=varargin{i+1};
      if ~ischar(Str),
        break;
      else,
        switch lower(Str),
        case 'above',
          if nargin>i,
            i=i+2;
            Val=varargin{i};
            if ~isnumeric(Val) | ~isequal(size(Val),[1 1]),
              error(sprintf('Invalid threshold value (argument %i).',i));
            else,
              Constr{c,2}=max(Constr{c,2},Val);
            end;
          else,
            error('Missing threshold value after ''above''.');
          end;
        case 'below',
          if nargin>i,
            i=i+2;
            Val=varargin{i};
            if ~isnumeric(Val) | ~isequal(size(Val),[1 1]),
              error(sprintf('Invalid threshold value (argument %i).',i));
            else,
              Constr{c,3}=min(Constr{c,3},Val);
            end;
          else,
            error('Missing threshold value after ''below''.');
          end;
        otherwise,
          break;
        end;
      end;
    end;
  end;
  i=i+1;
end;
NConstr=size(Constr,1);

if ~plotit & NPropsOut>(4+NConstr),
  error('Too many output arguments.');
end;

if isempty(whichcaps),
  whichcaps={'all'};
elseif ~isempty(strmatch('none',whichcaps)),
  whichcaps={};
end;

NaNs=isnan(X0) | isnan(Y0) | isnan(Z0);
if ~isempty(C0)
  NaNs=NaNs | isnan(C0);
end;
for c=1:NConstr,
  NaNs=NaNs | isnan(Constr{c,1});
end;
if any(NaNs(:)),
  Constr(end+1,:)={NaNs NaN eps};
  X0(isnan(X0))=0;
  Y0(isnan(Y0))=0;
  Z0(isnan(Z0))=0;
  if ~isempty(C0)
    C0(isnan(C0))=0;
  end;
  for c=1:NConstr,
    Constr{c,1}(isnan(Constr{c,1}))=0;
  end;
  NConstr=NConstr+1;
end;
NaNs=any(NaNs(:));

colorit=~isempty(C0);
NPropsOut=NPropsOut+colorit;
NPropsBase=4+colorit;             % tri,X,Y,Z,C?
NProps=NPropsBase+1+ 5*(NConstr-1); % [tri,X,Y,Z,C?],Di*1,D~i*5
TriSurf=[];
OutProps=cell(0,NPropsOut);
NSurf=0;
for c=1:NConstr+1,
  for thrsh=[2 3],
    if c>NConstr & thrsh==3, break; end;
    if c>NConstr | ~isnan(Constr{c,thrsh}),
      if c>NConstr, % isocaps
        if ~isempty(whichcaps), % selected caps
          if NaNs,
            fv=Local_isocaps(Constr{end,1},eps,'below',whichcaps{:});
          else,
            fv=Local_isocaps(ones(size(X0)),0,'above',whichcaps{:});
          end;
        else, % no caps
          fv.faces=zeros(0,3);
          fv.vertices=zeros(0,3);
        end;
      else, % isosurface
        val=Constr{c,thrsh};
        fv=isosurface(Constr{c,1},val);
      end;
      if ~isempty(fv.faces),
        NSurf=NSurf+1;
        AllProp=cell(1,NProps);
        AllProps{1}=fv.faces;
        AllProps{2}=interp3(X0,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
        AllProps{3}=interp3(Y0,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
        AllProps{4}=interp3(Z0,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
        if ~isempty(C0),
          AllProps{5}=isocolors(C0,fv.vertices);
        end;
        o=0;
        for c1=1:NConstr,
          if c1==c,
            o=o+1;
            AllProps{NPropsBase+o}=repmat(val,size(fv.vertices,1),1);
          else,
            AllProps{NPropsBase+o+1}=isocolors(Constr{c1,1},fv.vertices);
            AllProps{NPropsBase+o+2}='above';
            AllProps{NPropsBase+o+3}=Constr{c1,2};
            AllProps{NPropsBase+o+4}='below';
            AllProps{NPropsBase+o+5}=Constr{c1,3};
            o=o+5;
          end;
        end;
        SurfProps=cell(1,NPropsOut);
        [SurfProps{:}]=triconstrain(AllProps{:});
        if plotit,
          TriSurf(NSurf).faces=SurfProps{1};
          TriSurf(NSurf).vertices=[SurfProps{2} SurfProps{3} SurfProps{4}];
          if colorit,
            TriSurf(NSurf).facevertexcdata=SurfProps{5};
          end;
        else,
          OutProps(NSurf,:)=SurfProps;
        end;
      end;
    end;
  end;
end;

if plotit,
  NFace=0;
  NVert=0;
  for n=1:NSurf,
    NFace=NFace+size(TriSurf(n).faces,1);
    NVert=NVert+size(TriSurf(n).vertices,1);
  end;
  fv.faces=zeros(NFace,3);
  fv.vertices=zeros(NVert,3);
  if plotit,
    fv.facevertexcdata=zeros(NVert,1);
  end;
  NFace=0;
  NVert=0;
  for n=1:NSurf,
    tsnf=TriSurf(n).faces;
    tsnv=TriSurf(n).vertices;
    stsnf=size(tsnf,1);
    stsnv=size(tsnv,1);
    if stsnf~=0,
      fv.faces(NFace+(1:stsnf),:)=tsnf+NVert;
      fv.vertices(NVert+(1:stsnv),:)=tsnv;
      if colorit,
        fv.facevertexcdata(NVert+(1:stsnv),:)=TriSurf(n).facevertexcdata;
      end;
      NFace=NFace+stsnf;
      NVert=NVert+stsnv;
    end;
  end;
  if isempty(fv.faces),
    handle=[];
  else,
    if colorit,
      [DUMMY,I,J]=unique([fv.vertices fv.facevertexcdata],'rows');
      fv.vertices=fv.vertices(I,:);
      fv.facevertexcdata=fv.facevertexcdata(I);
      fv.faces=J(fv.faces);
      handle=patch(fv,'facecolor','interp','edgecolor','none');
    else,
      [fv.vertices,I,J]=unique(fv.vertices,'rows');
      fv.faces=J(fv.faces);
      handle=patch(fv);
    end;
  end;
  if nargout==1,
    varargout={handle};
  end;
else,
  NFace=0;
  for n=1:NSurf,
    NFace=NFace+size(OutProps{n,1},1);
  end;
  Out{1}=zeros(NFace,3);
  NFace=0;
  NVert=0;
  for n=1:NSurf,
    opn=OutProps{n,1};
    sopn=size(opn,1);
    if sopn~=0,
      Out{1}(NFace+(1:sopn),:)=opn+NVert;
      NFace=NFace+sopn;
      NVert=NVert+size(OutProps{n,2},1);
    end;
  end;
  for i=2:NPropsOut,
    Out{i}=zeros(NVert,3);
    NVert=0;
    for i=1:n,
      opn=OutProps{n,2};
      sopn=size(opn,1);
      if sopn~=0,
        fv.vertices(NVert+(1:sopn),:)=opn;
        NVert=NVert+sopn;
      end;
    end;
  end;
  varargout=Out;
end;


function fv = Local_isocaps(data,value,enclose,varargin)
%LOCAL_ISOCAPS  Isosurface end caps.
%   FV = LOCAL_ISOCAPS(V,ISOVALUE,ENCLOSE,PLANE1,PLANE2, ...)
%   PLANEi (i=1,2,...) describes for which planes the end caps will
%   be generated.  PLANEi can be one of 'all' (default), 'xmin',
%   'xmax', 'ymin', 'ymax', 'zmin', or 'zmax'. ENCLOSE is 'above' or
%   'below'.
%
%   See also ISOCAPS

%   Based on ISOCAPS:
%     Copyright (c) 1984-98 by The MathWorks, Inc.
%     $Revision$  $Date$

vmin = min([data(:); value]);
vmax = max([data(:); value]);
if enclose(1)=='b'
  pad = vmax+1;
else
  pad = vmin-1;
end

sz = size(data);
vv = [];

if nargin==3 | ~isempty(strmatch('all',varargin)),
  planes={'xmin','xmax','ymin','ymax','zmin','zmax'};
else,
  planes=unique(varargin);
end;

maxvert = 0; 
f = []; v = []; c = [];
for i=1:length(planes),
  ff=[]; vv=[];
  switch(planes{i})
  case 'xmin'
    data2 = pad+zeros(sz(1), 2, sz(3));
    data2(:,2,:) = data(:,1,:);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,1) = 1;
    end
  case 'xmax'
    data2 = pad+zeros(sz(1), 2, sz(3));
    data2(:,1,:) = data(:,end,:);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,1) = sz(2);
    end
  case 'ymin'
    data2 = pad+zeros(2, sz(2), sz(3));
    data2(2,:,:) = data(1,:,:);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,2) = 1;
    end
  case 'ymax'
    data2 = pad+zeros(2, sz(2), sz(3));
    data2(1,:,:) = data(end,:,:);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,2) = sz(1);
    end
  case 'zmin'
    data2 = pad+zeros(sz(1), sz(2), 2);
    data2(:,:,2) = data(:,:,1);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,3) = 1;
    end
  case 'zmax'
    data2 = pad+zeros(sz(1), sz(2), 2);
    data2(:,:,1) = data(:,:,end);
    [ff vv] = isosurface(data2, value);
    if ~isempty(vv)
      vv(:,3) = sz(3);
    end
  otherwise
    error('WHICHPLANE can be: all, xmin, xmax, ymin, ymax, zmin, zmax.');
  end    
  f = [f; ff+maxvert]; v = [v; vv];
  maxvert = maxvert + size(vv,1);
end;
fv.faces = f;
fv.vertices = v;