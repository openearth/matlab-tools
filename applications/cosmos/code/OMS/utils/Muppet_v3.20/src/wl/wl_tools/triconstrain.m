function varargout=triconstrain(varargin),
%TRICONSTRAIN constrain a triangulated surface
%    [TRI1,X1,Y1,Z1,D1_1,D2_1,....]= ...
%        TRICONSTRAIN(TRI0,X0,Y0,Z0,...
%                     D1_0,CondStr1,V1, ...
%                     D2_0,CondStr2,V2, ... )
%    TRI1,X1,Y1,Z1 subsection of the triangulated surface TRI0,
%    X0,Y0,Z0 constrained by the specified conditions. Each con-
%    straining condition consists of a dataset (values specified
%    at X0,Y0,Z0 positions) followed by one or more combinations
%    of a condition string ('below' or 'above') and a threshold
%    value.
%
%    H=TRICONSTRAIN(...,'color',CDATA)
%    Plots the constrained surface and returns the handles. The
%    surface is colored using the specified CDATA (same size as
%    X0, Y0, and Z0.
%
%    See also: VOLSURF, ISOSURF, ISOSURFACE, ISOCOLORS,
%              TRICONTOURF

%    (c) copyright July 2000, H.R.A. Jagers, bert.jagers@wldelft.nl
%                   WL | Delft Hydraulics, Delft, The Netherlands
%                   http://www.wldelft.nl

if nargin<4,
  error('Not enough input arguments');
end;

TRI=varargin{1};
X0=varargin{2};
Y0=varargin{3};
Z0=varargin{4};
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

i=5;
while i<=nargin,
  D=varargin{i};
  if ischar(D),
    switch lower(D),
    case 'color',
      if nargin>i,
        i=i+1;
        C0=varargin{i};
        if ~isequal(size(C0),size(X0)),
          error(sprintf('Unexpected size of color dataset (argument %i).',i));
        end;
      else,
        error('Missing color dataset.');
      end;
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

%NaNs=isnan(X0) | isnan(Y0) | isnan(Z0);
%if ~isempty(C0)
%  NaNs=NaNs | isnan(C0);
%end;
%for c=1:size(Constr,1),
%  NaNs=NaNs | isnan(Constr{c,1});
%end;
%if any(NaNs(:)),
%  Constr(end+1,:)={NaNs NaN eps};
%end;
NConstr=size(Constr,1);
colorit=~isempty(C0);
NPropsOut=NPropsOut+colorit;

if colorit,
  Out={TRI X0 Y0 Z0 C0 Constr{:,1}};
else,
  Out={TRI X0 Y0 Z0 Constr{:,1}};
end;

for c=NConstr:-1:1,
  i=4+colorit+c;
  k=1:max(i-1,NConstr);
  if ~isnan(Constr{c,2}) | ~isnan(Constr{c,3}),
    [Out{k}]=triconstr(Out{i},Constr{c,2},Constr{c,3},Out{k});
  end;
end;

if nargout==1,
  fv.faces=Out{1};
  fv.vertices=[Out{2} Out{3} Out{4}];
  if colorit,
    fv.facevertexcdata=Out{5};
  end;
  h=patch(fv);
  if nargout==1,
    varargout={h};
  end;
else,
  % assume unchanged
%  Out={TRI X0 Y0 Z0 Constr{:,1}};
  varargout=Out(1:nargout);
end;


function varargout=triconstr(V,Vmin,Vmax,tri,varargin);
% TRICONSTR Constrain triangulated data
%
%    TRICONSTR(V,Vmin,Vmax,TRI,X,Y,Z,Prop1,Prop2,...)

if nargin<4,
  error('Not enough input arguments.');
end;

In={tri varargin{:}};
Out={tri varargin{:}};
NOut=length(Out);
if isnan(Vmin) & isnan(Vmax),
  varargout=Out(1:nargout);
  return;
end;

V=V(:);
maxfinite=max(Vmax,max(V(isfinite(V(:)))));
minfinite=min(Vmin,min(V(isfinite(V(:)))));
V(V==-inf)=-realmax;
V(V==+inf)=realmax;

Patches=1:size(tri,1);
if isnan(Vmin),
  Smaller=logical(any(isnan(V(tri)),2)*[1 1 1]);
else,
  Smaller=~(V(tri)>=Vmin);
end;
Nsmaller=sum(Smaller,2);
if isnan(Vmax),
  Larger=logical(any(isnan(V(tri)),2)*[1 1 1]);
else,
  Larger=(V(tri)>=Vmax);
end;
Nlarger=sum(Larger,2);
CLIndex=6-Nsmaller+3*Nlarger; % Nsmaller+2*(3-Nsmaller-Nlarger)+5*Nlarger;

NTriangles=[0 0 0 1 2 1 2 3 2 0 2 1 0 0 0 0];
NPoints =  [0 0 0 3 4 3 4 5 4 0 4 3 0 0 0 0];

NPoints=sum(NPoints(CLIndex));
for i=2:NOut
  Out{i}=zeros([NPoints 1]);
end;
NTriangles=sum(NTriangles(CLIndex));
TRI=ones(NTriangles,3);
TRIOffset=0;
PNTOffset=0;

% patches with three smaller
%Patch=Patches(CLIndex==3);

% patches with two smaller than Vmin and one between Vmin and Vmax
Patch=Patches(CLIndex==4);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  Lambda1=(Vmin-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda2=(Vmin-V(Index(:,2)))./(V(Index(:,3))-V(Index(:,2)));
  PNTIndex=PNTOffset+(1:(3*length(Patch)));
  DPoint=zeros(3,size(Index,1));
  for i=2:NOut,
    DPoint(1,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(2,:)=transpose(In{i}(Index(:,2))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,2))));
    DPoint(3,:)=transpose(In{i}(Index(:,3)));
    Out{i}(PNTIndex)=DPoint(:);
  end;

  TRIIndex=TRIOffset+(1:length(Patch));
  TRI(TRIIndex,:)=transpose(reshape(PNTIndex,[3 length(Patch)]));
  TRIOffset=TRIOffset+length(Patch);

  PNTOffset=PNTOffset+3*length(Patch);
end;

% patches with one smaller than Vmin and two between Vmin and Vmax
Patch=Patches(CLIndex==5);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  Lambda1=(Vmin-V(Index(:,1)))./(V(Index(:,2))-V(Index(:,1)));
  Lambda2=(Vmin-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  PNTIndex=PNTOffset+(1:(4*length(Patch)));
  DPoint=zeros(4,size(Index,1));
  for i=2:NOut,
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,2))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,1))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(1,:)=transpose(In{i}(Index(:,2)));
    DPoint(4,:)=transpose(In{i}(Index(:,3)));
    Out{i}(PNTIndex)=DPoint(:);
  end;
  
  TRIIndex=TRIOffset+(1:2:(2*length(Patch)));
  PNTIndex=PNTOffset-1+(1:4:(4*length(Patch)));
  TRI(TRIIndex,:)=transpose(ones(3,1)*PNTIndex+[1;2;3]*ones(1,length(Patch)));
  TRI(TRIIndex+1,:)=transpose(ones(3,1)*PNTIndex+[1;3;4]*ones(1,length(Patch)));
  TRIOffset=TRIOffset+2*length(Patch);

  PNTOffset=PNTOffset+4*length(Patch);
end;

% patches with three between Vmin and Vmax
Patch=Patches(CLIndex==6);
if ~isempty(Patch),
  Index=reshape(transpose(tri(Patch,:)),[3*length(Patch) 1]);

  PNTIndex=PNTOffset+(1:(3*length(Patch)));
  for i=2:NOut,
    Out{i}(PNTIndex)=In{i}(Index);
  end;

  TRIIndex=TRIOffset+(1:length(Patch));
  TRI(TRIIndex,:)=transpose(reshape(PNTIndex,[3 length(Patch)]));
  TRIOffset=TRIOffset+length(Patch);

  PNTOffset=PNTOffset+3*length(Patch);
end;

% patches with two smaller than Vmin and one larger than Vmax
Patch=Patches(CLIndex==7);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  DPoint=zeros(4,size(Index,1));
  Lambda1=(Vmin-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda2=(Vmin-V(Index(:,2)))./(V(Index(:,3))-V(Index(:,2)));
  Lambda3=(Vmax-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda4=(Vmax-V(Index(:,2)))./(V(Index(:,3))-V(Index(:,2)));
  PNTIndex=PNTOffset+(1:(4*length(Patch)));
  for i=2:NOut,
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,2))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,2))));
    DPoint(1,:)=transpose(In{i}(Index(:,1))+Lambda3.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(4,:)=transpose(In{i}(Index(:,2))+Lambda4.*(In{i}(Index(:,3))-In{i}(Index(:,2))));
    Out{i}(PNTIndex)=DPoint(:);
  end;
  
  TRIIndex=TRIOffset+(1:2:(2*length(Patch)));
  PNTIndex=PNTOffset-1+(1:4:(4*length(Patch)));
  TRI(TRIIndex,:)=transpose(ones(3,1)*PNTIndex+[1;2;3]*ones(1,length(Patch)));
  TRI(TRIIndex+1,:)=transpose(ones(3,1)*PNTIndex+[1;3;4]*ones(1,length(Patch)));
  TRIOffset=TRIOffset+2*length(Patch);

  PNTOffset=PNTOffset+4*length(Patch);
end;

% patches with one smaller than Vmin, one larger than Vmax and one between Vmin and Vmax
Patch=Patches(CLIndex==8);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  DPoint=zeros(5,size(Index,1));
  Lambda1=(Vmax-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda2=(Vmax-V(Index(:,2)))./(V(Index(:,3))-V(Index(:,2)));
  Lambda3=(Vmin-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda4=(Vmin-V(Index(:,1)))./(V(Index(:,2))-V(Index(:,1)));
  PNTIndex=PNTOffset+(1:(5*length(Patch)));
  for i=2:NOut,
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,2))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,2))));
    DPoint(1,:)=transpose(In{i}(Index(:,1))+Lambda3.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(4,:)=transpose(In{i}(Index(:,1))+Lambda4.*(In{i}(Index(:,2))-In{i}(Index(:,1))));
    DPoint(5,:)=transpose(In{i}(Index(:,2)));
    Out{i}(PNTIndex)=DPoint(:);
  end;

  TRIIndex=TRIOffset+(1:3:(3*length(Patch)));
  PNTIndex=PNTOffset-1+(1:5:(5*length(Patch)));
  TRI(TRIIndex,:)=transpose(ones(3,1)*PNTIndex+[1;2;3]*ones(1,length(Patch)));
  TRI(TRIIndex+1,:)=transpose(ones(3,1)*PNTIndex+[1;3;4]*ones(1,length(Patch)));
  TRI(TRIIndex+2,:)=transpose(ones(3,1)*PNTIndex+[3;4;5]*ones(1,length(Patch)));
  TRIOffset=TRIOffset+3*length(Patch);

  PNTOffset=PNTOffset+5*length(Patch);
end;

% patches with one larger than Vmax and two between Vmin and Vmax
Patch=Patches(CLIndex==9);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);
  
  DPoint=zeros(4,size(Index,1));
  Lambda1=(Vmax-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda2=(Vmax-V(Index(:,2)))./(V(Index(:,3))-V(Index(:,2)));
  PNTIndex=PNTOffset+(1:(4*length(Patch)));
  for i=2:NOut,
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,2))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,2))));
    DPoint(1,:)=transpose(In{i}(Index(:,1)));
    DPoint(4,:)=transpose(In{i}(Index(:,2)));
    Out{i}(PNTIndex)=DPoint(:);
  end;

  TRIIndex=TRIOffset+(1:2:(2*length(Patch)));
  PNTIndex=PNTOffset-1+(1:4:(4*length(Patch)));
  TRI(TRIIndex,:)=transpose(ones(3,1)*PNTIndex+[1;2;3]*ones(1,length(Patch)));
  TRI(TRIIndex+1,:)=transpose(ones(3,1)*PNTIndex+[1;3;4]*ones(1,length(Patch)));
  TRIOffset=TRIOffset+2*length(Patch);

  PNTOffset=PNTOffset+4*length(Patch);
end;

% patches with one smaller than Vmin and two larger than Vmax
Patch=Patches(CLIndex==11);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  DPoint=zeros(4,size(Index,1));
  Lambda1=(Vmin-V(Index(:,1)))./(V(Index(:,2))-V(Index(:,1)));
  Lambda2=(Vmin-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  Lambda3=(Vmax-V(Index(:,1)))./(V(Index(:,2))-V(Index(:,1)));
  Lambda4=(Vmax-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  PNTIndex=PNTOffset+(1:(4*length(Patch)));
  for i=2:NOut,
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,2))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,1))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(1,:)=transpose(In{i}(Index(:,1))+Lambda3.*(In{i}(Index(:,2))-In{i}(Index(:,1))));
    DPoint(4,:)=transpose(In{i}(Index(:,1))+Lambda4.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    Out{i}(PNTIndex)=DPoint(:);
  end;

  TRIIndex=TRIOffset+(1:2:(2*length(Patch)));
  PNTIndex=PNTOffset-1+(1:4:(4*length(Patch)));
  TRI(TRIIndex,:)=transpose(ones(3,1)*PNTIndex+[1;2;3]*ones(1,length(Patch)));
  TRI(TRIIndex+1,:)=transpose(ones(3,1)*PNTIndex+[1;3;4]*ones(1,length(Patch)));
  TRIOffset=TRIOffset+2*length(Patch);

  PNTOffset=PNTOffset+4*length(Patch);
end;

% patches with two larger than Vmax and one between Vmin and Vmax
Patch=Patches(CLIndex==12);
if ~isempty(Patch),
  Index=tri(Patch,:);
  [Dummy,Permutation]=sort(reshape(V(Index),[length(Patch) 3]),2);
  Index=Index((Permutation-1)*size(Index,1)+transpose(1:size(Index,1))*[1 1 1]);

  DPoint=zeros(3,size(Index,1));
  Lambda1=(Vmax-V(Index(:,1)))./(V(Index(:,2))-V(Index(:,1)));
  Lambda2=(Vmax-V(Index(:,1)))./(V(Index(:,3))-V(Index(:,1)));
  PNTIndex=PNTOffset+(1:(3*length(Patch)));
  for i=2:NOut,
    DPoint(1,:)=transpose(In{i}(Index(:,1))+Lambda1.*(In{i}(Index(:,2))-In{i}(Index(:,1))));
    DPoint(2,:)=transpose(In{i}(Index(:,1))+Lambda2.*(In{i}(Index(:,3))-In{i}(Index(:,1))));
    DPoint(3,:)=transpose(In{i}(Index(:,1)));
    Out{i}(PNTIndex)=DPoint(:);
  end;

  TRIIndex=TRIOffset+(1:length(Patch));
  TRI(TRIIndex,:)=transpose(reshape(PNTIndex,[3 length(Patch)]));
  TRIOffset=TRIOffset+length(Patch);

  PNTOffset=PNTOffset+3*length(Patch);
end;

% patches with three larger
%Patch=Patches(CLIndex==15);

%[Coord,I,J]=unique(Coord,'rows');
%TRI=J(TRI);
Out{1}=TRI;
varargout=Out(1:nargout);