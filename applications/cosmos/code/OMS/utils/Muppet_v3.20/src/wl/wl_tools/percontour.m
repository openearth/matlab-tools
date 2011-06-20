function [cc,h]=percontour(varargin)
%PERCONTOUR Contour data with a periodic range
%    A standard CONTOUR plot of a value that has
%    some periodic meaning (e.g. a phase) results
%    in a bunch of contour lines where the values
%    wrap around from the maximum to the minimum
%    value. PERCONTOUR solves this problem by
%    selective blanking and periodic wrapping of
%    data.
%
%    The allowed syntax of PERCONTOUR is the same
%    that of CONTOUR with one exception:
%        ...,'periodicity',P,...
%    sets the periodicity (2*pi by default).
%    The output is compatible with CLABEL. Values
%    and thresholds are reduced to their primary
%    value.
%
%    See Also: CONTOUR, CLABEL

% (c) 2001, H.R.A. Jagers
%           WL | Delft Hydraulics, The Netherlands

X={}; Y={}; Z={}; v={}; linstyl={};
i=0;
Periodicity=2*pi;
while i<nargin
  i=i+1;
  if ischar(varargin{i})
    switch lower(varargin{i})
    case 'periodicity'
      i=i+1;
      Periodicity=varargin{i};
    otherwise
      linstyl=varargin{i};
    end
  elseif isnumeric(varargin{i})
    if iscell(X)
      X=varargin{i};
    elseif iscell(Y)
      Y=varargin{i};
    elseif iscell(Z)
      Z=varargin{i};
    elseif iscell(v)
      v=varargin{i};
    else
      error('Invalid input arguments');
    end
  else
    error(sprintf('Invalid input argument %i',i));
  end
end

if iscell(X)
  error('Invalid input arguments');
elseif iscell(Y) % Z (default N=10)
  v=10;
  Z=X;
  X={};
elseif iscell(Z) % Z, v or Z,N
  v=Y;
  Z=X;
  X={};
  Y={};
elseif iscell(v) % X,Y,Z (default N=10)
  v=10;
end

if ~iscell(X)
 if ~isequal(size(X),size(Y),size(Z))
   error('Size mismatch X, Y, Z matrices')
 end
end


hPeriodicity=Periodicity/2;
qPeriodicity=Periodicity/4;

if ~iscell(X)
  args={X Y};
else
  args={};
end
if iscell(linstyl)
  args2={};
else
  args2={linstyl};
end

if size(v)==[1 1]
  v=Periodicity*(1:v)/v;
end
v=unique(mod(v,Periodicity));
Z=mod(Z,Periodicity);

c={};
h={};
for i=1:length(v)
  a=Z;
  Ind=a>v(i)+hPeriodicity;
  a(Ind)=a(Ind)-Periodicity;
  Ind=a<v(i)-hPeriodicity;
  a(Ind)=a(Ind)+Periodicity;
  Ind=a>v(i)+qPeriodicity | a<v(i)-qPeriodicity;
  a(Ind)=NaN;
  [c{i},h{i}]=contour(args{:},a,[v(i) v(i)],args2{:});
  if i==1, hold on; end
end

Ind=~cellfun('isempty',c);

c=cat(2,c{Ind});
h=cat(1,h{Ind});
if nargout>1,
  cc=c;
end