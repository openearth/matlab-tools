function varargout=xyveloc(varargin);
% XYVELOC Reads X,Y,U,V from a trim- or com-file.
%
%         [U,V]=XYVELOC(NFStruct,TimeStep);
%         Reads the velocity field at the specified timestep from
%         the specified NEFIS file. By default TimeStep is the last
%         field of the CURTIM or map-series group. The default NEFIS
%         file is the last opened NEFIS file.
%
%         [X,Y,U,V]=XYVELOC(NFStruct,TimeStep);
%         Reads also the coordinates of the gridpoints at which the
%         velocities are given (waterlevel points).
%         
%         [U,V,W]=XYVELOC(NFStruct,Index);
%         Reads a 3D velocity field.
%
%         [X,Y,Z,U,V,W]=XYVELOC(NFStruct,Index);
%         Reads the 3D velocity field and returns the 3D coordinates
%         of the velocity values.
%
%         [...]=XYVELOC(...,'option')
%         where option equals:
%         * total, fluc, mean
%           Reads the total velocity, fluctuation component, or mean
%           velocity field in case of a HLES simulation. (trim-file,
%           2D only).
%           Default seting is 'total'.
%         * vort
%           Computes the z-component of the vorticity:
%           Vort=XYVELOC(...,'vort')
%
%         See also: VS_USE, VS_GET, VS_LET

% (c) copyright 1/7/2000, H.R.A. Jagers, WL | Delft Hydraulics

if nargout<1,
  error('Not enough output arguments.');
elseif nargout>6,
  error('Too many output arguments.');
end;

C=vs_use('lastread');
j=1;
if (nargin>0) & isstruct(varargin{j}),
  C=varargin{j};
  j=j+1;
end;

switch vs_type(C),
case 'Delft3D-com',
  Info=vs_disp(C,'CURTIM',[]);
  i0=Info.SizeDim;
  i=Info.SizeDim;
case 'Delft3D-trim',
  Info=vs_disp(C,'map-series',[]);
  i0=Info.SizeDim;
  i=Info.SizeDim;
end;

if (nargin>=j) & ~ischar(varargin{j}),
  i=varargin{j};
  j=j+1;
end;

Type='total';
Spec='no'; SpecOut=0;
UserSpecUV=0;
k=j;
while k<=nargin,
  if ischar(varargin{k}),
    switch lower(varargin{k}),
    case {'total','fluc','mean'},
      Type=lower(varargin{k});
      k=k+1;
    case {'vort','relstdfluc'},
      Spec=lower(varargin{k});
      SpecOut=1;
      k=k+1;
    case 'stdfluc',
      Spec=lower(varargin{k});
      SpecOut=2;
      k=k+1;
    case {'uv'},
      UserSpecUV=1;
      U=varargin{k+1};
      V=varargin{k+2};
      k=k+3;
    otherwise,
      warning(sprintf('Unknown option: %s.',varargin{k}));
    end;
  end;
end;

if strcmp(Spec,'no'),
  if nargout<2,
    error('Not enough output arguments.');
  end;
else,
  if nargout~=SpecOut,
    error('Invalid number of output arguments.');
  end;
end;

threeD = (nargout>2) & (nargout~=4); % 3D output requested

switch vs_type(C),
case {'Delft3D-com','Delft3D-trim'},
otherwise,
  error('Invalid NEFIS file for this action.');
end;

if UserSpecUV,
  if ~strcmp(Type,'total'),
    warning('Velocity field type ignored in case of user specified data.');
    Type='total';
  end;
  kfu=U~=0;
  kfv=V~=0;
else,
  switch vs_type(C),
  case 'Delft3D-com',
    if ~strcmp(Type,'total'),
      warning('Only ''total'' velocity supported for com-file.');
      Type='total';
    end;
    U=vs_get(C,'CURTIM',{i},'U1','quiet');
    V=vs_get(C,'CURTIM',{i},'V1','quiet');
    if threeD,
      warning('Only U and V components available in com-file.');
      W=zeros(size(U));
    end;
    kfu=vs_get(C,'KENMTIM',{i},'KFU','quiet');
    kfv=vs_get(C,'KENMTIM',{i},'KFV','quiet');
  case 'Delft3D-trim',
    if threeD & ~strcmp(Type,'total'),
      warning('Only ''total'' velocity supported for 3D calculations.');
      Type='total';
    end;
    switch Type,
    case 'total',
      U=vs_get(C,'map-series',{i},'U1','quiet');
      V=vs_get(C,'map-series',{i},'V1','quiet');
      if threeD,
        W=vs_get(C,'map-series',{i},'WPHY','quiet');
      end;
    case 'mean',
      U=vs_get(C,'map-series',{i},'UMNLDF','quiet');
      V=vs_get(C,'map-series',{i},'VMNLDF','quiet');
    case 'fluc',
      U=vs_get(C,'map-series',{i},'U1','quiet');
      V=vs_get(C,'map-series',{i},'V1','quiet');
      UM=vs_get(C,'map-series',{i},'UMNLDF','quiet');
      VM=vs_get(C,'map-series',{i},'VMNLDF','quiet');
      U=U-UM;
      V=V-VM;
    end;
    kfu=vs_get(C,'map-series',{i},'KFU','quiet');
    kfv=vs_get(C,'map-series',{i},'KFV','quiet');
  end;
end;

actu=max(1,conv2([kfu(:,1)>0 kfu>0],[1 1],'valid'));
actv=max(1,conv2([kfv(1,:)>0;kfv>0],[1;1],'valid'));
kmax=size(U,3);
for k=1:kmax, % for each layer
  U(:,:,k)=U(:,:,k).*kfu;
  V(:,:,k)=V(:,:,k).*kfv;
end;

if ~strcmp(Spec,'no'),
  switch Spec,
  case 'vort',
    switch vs_type(C),
    case 'Delft3D-com',
      XZ=vs_get(C,'TEMPOUT','XWAT','quiet');   
      YZ=vs_get(C,'TEMPOUT','YWAT','quiet');   
    case 'Delft3D-trim',
      XZ=vs_get(C,'map-const','XZ','quiet');   
      YZ=vs_get(C,'map-const','YZ','quiet');   
    end;
    DU=U([2:end end],:,:)-U;
    DV=V(:,[2:end end],:)-V;
    XZdY=conv2(XZ,[1 1;-1 -1]/2,'same'); 
    YZdY=conv2(YZ,[1 1;-1 -1]/2,'same');   
    distUU=sqrt(XZdY.^2+YZdY.^2);  
    distUU(distUU==0)=1;  
    XZdX=conv2(XZ,[1 -1;1 -1]/2,'same');  
    YZdX=conv2(YZ,[1 -1;1 -1]/2,'same');
    distVV=sqrt(XZdX.^2+YZdX.^2);
    distVV(distVV==0)=1;
    for k=kmax:-1:1, % for each layer
      Vort(:,:,k)=DV(:,:,k)./distVV-DU(:,:,k)./distUU;
    end;
    varargout={Vort};
    return;
  case {'relstdfluc','stdfluc'},
    U2Sum=zeros(size(U));
    V2Sum=U2Sum;
    UMSum=U2Sum; VMSum=UMSum;
    if kmax>1,
      WMSum=U2Sum; W2Sum=UMSum;
    end;
    h0=waitbar(0,'Please wait while computing ...');
    try,
      for i=1:i0,
        U=vs_get(C,'map-series',{i},'U1','quiet');
        V=vs_get(C,'map-series',{i},'V1','quiet');
        % interpolate velocities
        U=U+U(:,[1 1:end-1],:);
        V=V+V(:,[1 1:end-1],:);
        for k=1:kmax, % for each layer
          U(:,:,k)=U(:,:,k)./actu;
          V(:,:,k)=V(:,:,k)./actv;
        end;
        U2Sum=U2Sum+U.^2;
        V2Sum=V2Sum+V.^2;
        UMSum=UMSum+U;
        VMSum=VMSum+V;
        if kmax>1,
          W=vs_get(C,'map-series',{i},'WPHYS','quiet');
          W2Sum=W2Sum+W.^2;
          WMSum=WMSum+W;
        end;
        if ishandle(h0), waitbar(i/i0,h0); end;
      end;
    catch,
    end;
    if ishandle(h0), close(h0); end;
    U2Sum=(U2Sum-(UMSum.^2)/i0)/(i0-1);
    V2Sum=(V2Sum-(VMSum.^2)/i0)/(i0-1);
    UMSum=UMSum/i0;
    VMSum=VMSum/i0;
    if kmax>1,
      W2Sum=(W2Sum-(WMSum.^2)/i0)/(i0-1);
      WMSum=WMSum/i0;
    end;
    switch Spec,
    case 'stdfluc',
      if kmax==1,
        varargout={sqrt(U2Sum) sqrt(V2Sum)};
      else, % kmax>1
        varargout={sqrt(U2Sum) sqrt(V2Sum) sqrt(W2Sum)};
      end;
    case 'relstdfluc',
      if kmax==1,
        U2Sum=sqrt(U2Sum+V2Sum);
        UMSum=sqrt(UMSum.^2+VMSum.^2);
      else, % kmax>1
        U2Sum=sqrt(U2Sum+V2Sum+W2Sum);
        UMSum=sqrt(UMSum.^2+VMSum.^2+WMSum.^2);
      end;
      UMSum(UMSum==0)=NaN;
      varargout={U2Sum./UMSum};
    end;
    return;
  end;
end;

switch vs_type(C),
case 'Delft3D-com',
  alfa=vs_get(C,'GRID','ALFAS','quiet');
  alfa0=vs_get(C,'GRID','ALFORI','quiet');
  alfa=alfa+alfa0;
case 'Delft3D-trim',
  alfa=vs_get(C,'map-const','ALFAS','quiet');
%  alfa0=vs_get(C,'map-const','ALFORI','quiet');
%  alfa=alfa+alfa0;
end;
alfa=alfa*pi/180;

% interpolate and reorient
U=U+U(:,[1 1:end-1],:);
V=V+V([1 1:end-1],:,:);
for k=kmax:-1:1, % for each layer
  U(:,:,k)=U(:,:,k)./actu;
  V(:,:,k)=V(:,:,k)./actv;
  UU(:,:,k)=U(:,:,k).*cos(alfa)-V(:,:,k).*sin(alfa);
  VV(:,:,k)=U(:,:,k).*sin(alfa)+V(:,:,k).*cos(alfa);
end;

if nargout==2, % U,V
  varargout={UU VV};
  return;
elseif nargout==3, % U,V,W
  varargout={UU VV W};
  return;
end;

switch vs_type(C),
case 'Delft3D-com',
  kcs=vs_get(C,'KENMCNST','KCS','quiet')~=0;
  X=vs_get(C,'TEMPOUT','XWAT','quiet');
  Y=vs_get(C,'TEMPOUT','YWAT','quiet');
  X0=vs_get(C,'GRID','XORI','quiet');
  Y0=vs_get(C,'GRID','YORI','quiet');
  X=X+X0;
  Y=Y+Y0;
case 'Delft3D-trim',
  kcs=vs_get(C,'map-const','KCS','quiet')~=0;
  X=vs_get(C,'map-const','XZ','quiet');
  Y=vs_get(C,'map-const','YZ','quiet');
%  X=vs_get(C,'TEMPOUT','XWAT','quiet');
%  Y=vs_get(C,'TEMPOUT','YWAT','quiet');
%  X0=vs_get(C,'map-const','XORI','quiet');
%  Y0=vs_get(C,'map-const','YORI','quiet');
%  X=X+X0;
%  Y=Y+Y0;
end;
% X(~kcs)=NaN; % includes open boundaries
X(kcs~=1)=NaN;
Y(kcs~=1)=NaN;

if nargout==4, % X,Y,U,V
  varargout={X Y UU VV};
elseif nargout==5, % X,Y,U,V,W
  varargout={X Y UU VV W};
  return;
else, %if nargout==6, % X,Y,Z,U,V,W
  switch vs_type(C), % not available for com-file
  case 'Delft3D-trim',
    S1=vs_get(C,'map-series',{i},'S1','quiet');
    S1(kcs~=1)=NaN;
    DP=vs_get(C,'map-const','DP0','quiet');
    DP=-corner2center(DP,'same');
    H=S1-DP;
    H(H<0)=NaN;
    sigma=vs_get(C,'map-const','THICK','quiet');
    sigma=cumsum([0;sigma(1:end-1)])+sigma/2;
    for k=kmax:-1:1,
      Z(:,:,k)=S1-H*sigma(k);
      X(:,:,k)=X(:,:,1);
      Y(:,:,k)=Y(:,:,1);
    end;
  end;
  varargout={X Y Z UU VV W};
  return;
end;
