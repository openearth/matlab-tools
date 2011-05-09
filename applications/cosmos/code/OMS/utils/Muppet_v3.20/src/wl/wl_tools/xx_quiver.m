function H = xx_quiver(Axes,Scale,varargin),
% XX_QUIVER Plots a vector field
%
%    Handle = xx_quiver(Axes,Scale,X,Y,U,V, ...)
%    Handle = xx_quiver(Axes,Scale,X,Y,U,V,C, ...)
%    Handle = xx_quiver(Axes,Scale,X,Y,Z,U,V,W, ...)
%    Handle = xx_quiver(Axes,Scale,X,Y,Z,U,V,W,C, ...)
%
%    Options:
%         'headtype'         [ { 'arrowhead' } | 'none' ]
%                            type of arrowhead
%         'headangle'        angle of arrow tip (default 60 degrees)
%         'headwidth'        direct specification of width, instead
%                            of headangle (in cm)
%         'headlength'       length of tip; set to 0 to omit arrowhead
%                            entirely (default 0.18 cm)
%         'shaftwidth'       width of arrow shaft (default 0.03 cm)
%         'alignment'        [ 'head' | 'centered' | { 'tail' } ]
%                            positioning of vector
%         'zdata'            a matrix of the same size as X,Y,U,V containing
%                            the zlevels of the vectors.
%         and any valid patch properties may be specified here;
%         they are passed directly to the patch function.
%
%    Note: papersize, size of axes, and axes limits should be fixed before
%          this function is called

% Based on:
% m_vec.m of the mapping toolbox M-Map version 1.2c 9/April/1998
%                   by Rich Pawlowicz, rich@ocgy.ubc.ca
% Mon 98/02/16 Eric Firing, efiring@soest.hawaii.edu
%
% Changed by H.R.A.Jagers, University of Twente, Delft Hydraulics, The Netherlands
%    bert.jagers@wldelft.nl

% Default arrow parameters:
zdata = [];
headtype='arrowhead';
centered = 'tail';
headlength = 5/72*2.54; % default 5 points, 5/72 inch, 5/72*2.54 cm
headwidth  = NaN;
headangle = 40;
shaftwidth = 1/72*2.54; % default 1 point, 1/72 inch, 1/72*2.54 cm
C = 'k';

if nargin<6,
  error('Not enough input arguments.');
end;

Sz=-ones(1,7);
for i=1:min(nargin-2,7),
  Sz(i)=prod(size(varargin{i}));
  if ischar(varargin{i}),
    break;
  end;
end;

if all(Sz==Sz(1)), % zeven equal size: X,Y,Z,U,V,W,C
  X=varargin{1};
  Y=varargin{2};
  Z=varargin{3};
  U=varargin{4};
  V=varargin{5};
  W=varargin{6};
  C=varargin{7};
  optvals = varargin(8:end);;
elseif all(Sz(1:6)==Sz(1)), % six equal size: X,Y,Z,U,V,W, (constant color?)
  X=varargin{1};
  Y=varargin{2};
  Z=varargin{3};
  U=varargin{4};
  V=varargin{5};
  W=varargin{6};
  if length(varargin)<7,
    OptStart=7;
  elseif ischar(varargin{7}), % char string?
    if isequal(size(varargin{7}),[1 1]) & ~isempty(findstr('rgbmcywk',varargin{7})),
      C=varargin{7};
      OptStart=8;
    else,
      OptStart=7;
    end;
  else,
    OptStart=8;
  end;
  optvals = varargin(OptStart:end);;
elseif all(Sz(1:5)==Sz(1)), % five equal size: X,Y,U,V,C
  X=varargin{1};
  Y=varargin{2};
  Z=[];
  U=varargin{3};
  V=varargin{4};
  W=[];
  C=varargin{5};
  optvals = varargin(6:end);;
elseif all(Sz(1:4)==Sz(1)), % four equal size: X,Y,U,V, (constant color?)
  X=varargin{1};
  Y=varargin{2};
  Z=[];
  U=varargin{3};
  V=varargin{4};
  W=[];
  if length(varargin)<5,
    OptStart=5;
  elseif ischar(varargin{5}), % char string?
    if isequal(size(varargin{5}),[1 1]) & ~isempty(findstr('rgbmcwk',varargin{5})),
      C=varargin{5};
      OptStart=6;
    else,
      OptStart=5;
    end;
  else,
    OptStart=5;
  end;
  optvals = varargin(OptStart:end);;
else,
  error('Invalid input arguments');
end;

if 2*round(length(optvals)/2)~=length(optvals),
  error('Invalid option-value pair');
else,
  optvals=reshape(optvals,[2 length(optvals)/2]);
end;

OptionUsed=logical(zeros(1,size(optvals,2)));
for i=1:size(optvals,2),
  if ~ischar(optvals{1,i}),
    error('Invalid option'),
  end;
  switch lower(optvals{1,i}),
  case 'headtype',
    headtype = optvals{2,i};
    OptionUsed(i)=1;
  case 'headlength',
    headlength = optvals{2,i};
    OptionUsed(i)=1;
  case 'headwidth',
    headwidth = optvals{2,i};
    OptionUsed(i)=1;
  case 'headangle',
    headangle = optvals{2,i};
    OptionUsed(i)=1;
  case 'shaftwidth',
    shaftwidth = optvals{2,i};
    OptionUsed(i)=1;
  case 'alignment',
    centered = lower(optvals{2,i});
    OptionUsed(i)=1;
  case 'zdata',
    zdata = optvals{2,i};
    if ~isequal(size(zdata),size(X)),
      error('Size of zdata does not match size of xdata.');
    end;
    OptionUsed(i)=1;
  end
end;
optvals(:,OptionUsed)=[]; % delete used options
optvals=optvals(:);

% Calculate the headwidth if it is not given explicitly:
if isnan(headwidth) & headangle < 170 & headangle > 0
   headwidth = headlength * tan(headangle*pi/180);
end
headwidth = max([headwidth; shaftwidth]);

if Sz(1)==0, % empty plot
  H=patch('xdata',[],'ydata',[],optvals{:}); % empty plot
  return;
end;

if ischar(C),
  Clrs=[1 0 0; 0 1 0; 0 0 1; 1 0 1; 0 1 1; 1 1 0; 1 1 1; 0 0 0];
  C=Clrs(findstr('rgbmcywk',C),:);
elseif isequal(size(C),size(X)),
  C=C(:);
elseif ndims(C)==3,
  if isequal([size(C,1) size(C,2)],size(X)) & (size(C,3)==3) & ~any(C(:)>1) & ~any(C<0),
    C=reshape(C,[prod(size(X)) 3]);
  else,
    error('Incorrect color matrix size.');
  end;
elseif (size(C,2)==3) & ((size(C,1)==prod(size(X))) |  (size(C,1)==1)),
  % C=C;
else,
  error('Invalid color matrix.');
end;
X=X(:);
Y=Y(:);
Z=Z(:);
U=U(:);
V=V(:);
W=W(:);

if ~isempty(W),
  error('3D vectors not yet supported.');
end;

%% End of input argument parsing.
Fig=get(Axes,'parent');

OrigAxUnits = get(Axes,'Units');
if OrigAxUnits(1:3) == 'nor'
   OrigPaUnits = get(Fig, 'paperunits');
   set(Fig, 'paperunits', 'centimeters');
   figposCMs = get(Fig, 'paperposition');
   set(Fig, 'paperunits', OrigPaUnits);
   axposNor = get(Axes, 'position');
   axWidLenCMs = axposNor(3:4) .* figposCMs(3:4);
else
   set(Axes, 'units', 'centimeters');
   axposCMs = get(Axes, 'position');
   set(Axes, 'units', OrigAxUnits);
   axWidLenCMs = axposCMs(3:4);
end

% Multiply CMs by the following to get data units:
scX = diff(get(Axes, 'XLim'))/axWidLenCMs(1);
scY = diff(get(Axes, 'YLim'))/axWidLenCMs(2);
sc  = max([scX;scY]);  % max selects the dimension limited by
                       % the plot box.

Width = shaftwidth*sc;
HeadWidth = headwidth*sc;
HeadLength = headlength*sc;

UVmag = sqrt(U.^2 + V.^2);
% Arrow lengths in plot data units:
L = UVmag*sc/Scale;

U=U+realmin; % make sure that U and V are not both zero
Ang = atan2(V,U);

nvec = length(L);
Zero = zeros(nvec,1);
One  = ones(nvec,1);

% Normal arrow dimensions:
HL = Zero+HeadLength;
HW = Zero+HeadWidth;
W =  Zero+Width;

% Distinguish zero-length vectors from non-zero:
mm = (L < 100*eps);
i_zero = find(mm);
i_nonzero = find(~mm);
% Don't plot if length is zero.
if ~isempty(i_zero)
  HL(i_zero) = NaN; HW(i_zero) = NaN; W(i_zero) = NaN;
end

if ~isempty(i_nonzero)
  ii = i_nonzero;
  if HeadLength == 0,   %% square end; no arrowhead
    W(ii)  = Width;
    HW(ii) = Width;
    HL(ii) = Zero;
  else
    % If the arrow length is less than the headlength,
    % omit the arrow shaft and just plot a head scaled
    % to the length.
    i_short = ii( find(L(ii) < HeadLength) );
    W(i_short)  = 0;
    HL(i_short) = L(i_short);
    HW(i_short) = HL(i_short) * (HeadWidth/HeadLength);
  end
end

switch centered,
case 'head',
  Xzero = -L;
case 'centered',
  Xzero = -L/2;
otherwise, % tail
  Xzero = Zero;
end

switch headtype,
case 'none',
  nVpA=5;
  nV = 5*nvec;  % number of Vertices: 5 per arrow.
  Vert = zeros(nvec,2);
  
  Vert(1:5:nV,:) =  [Xzero,  W/2];                     % back corner of shaft
  Vert(2:5:nV,:) = Vert(1:5:nV,:) + [L, Zero];         % front corner of shaft
  % Reflect the top half to get the bottom half.
  % First replicate:
  Vert(3:5:nV,:) = Vert(2:5:nV,:);
  Vert(4:5:nV,:) = Vert(1:5:nV,:);
  % Then negate y to reflect:
  Vert(3:5:nV,2) = -Vert(3:5:nV,2);
  Vert(4:5:nV,2) = -Vert(4:5:nV,2);
otherwise, % 'arrowhead'
  nVpA=7;
  nV = 7*nvec;  % number of Vertices: 7 per arrow.
  Vert = zeros(nvec,2);
  
  Vert(1:7:nV,:) =  [Xzero,  W/2];                     % back corner of shaft
  Vert(2:7:nV,:) = Vert(1:7:nV,:) + [(L-HL), Zero];    % shaft-head junction
  Vert(3:7:nV,:) = Vert(2:7:nV,:) + [Zero, (HW-W)/2];  % point of barb
  Vert(4:7:nV,:) = [Xzero + L, Zero];                  % tip of arrow
  % Reflect the top half to get the bottom half.
  % First replicate:
  Vert(5:7:nV,:) = Vert(3:7:nV,:);
  Vert(6:7:nV,:) = Vert(2:7:nV,:);
  Vert(7:7:nV,:) = Vert(1:7:nV,:);
  % Then negate y to reflect:
  Vert(5:7:nV,2) = -Vert(5:7:nV,2);
  Vert(6:7:nV,2) = -Vert(6:7:nV,2);
  Vert(7:7:nV,2) = -Vert(7:7:nV,2);
end;

% Make an index array for operating on all vertices of each vector:
ii = (1:nvec);
ii = ii(ones(nVpA,1),:);
ii = ii(:);

%% Rotate:
i=sqrt(-1);
Vxy = exp(i*Ang(ii)).*(Vert(:,1) + i*Vert(:,2));

%% Translate:
Vxy = Vxy + X(ii) + i*Y(ii);

%%
Vert(:,1) = real(Vxy);
Vert(:,2) = imag(Vxy);
if ~isempty(zdata),
  Vert(:,3) = zdata(ii);
end;

Faces = [1:nV].';            %Top
Faces = reshape(Faces,nVpA,nvec).';

% Extremely narrow patches don't show up on the screen (although they seem
% to be printed OK) when EdgeColor is 'none', so when the arrows are all
% the same color, set the EdgeColor to be the same as FaceColor.
H = patch('Parent',Axes,'Faces', Faces, 'Vertices', Vert);
if (size(C,1) == 1 & size(C,2) == 3),
   set(H, 'EdgeColor', C, 'FaceColor', C, 'LineWidth', 0.1, optvals{:});
else
   set(H, 'EdgeColor', 'none', 'FaceColor','Flat', ...
     'FaceVertexCdata', C, optvals{:});
end