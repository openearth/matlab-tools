function varargout=corner2center(varargin),
% CORNER2CENTER interpolate data from cell corners to cell centers
%       Interpolates coordinates/data from corners (DP) to
%       centers (S1). Supports 1D, 2D, and 3D data, single
%       block and multiblock. In case the output datasets should
%       have the same size as the input datasets, add the optional
%       argument 'same' to the input arguments.
%
%       XCenter=CORNER2CENTER(XCorner)
%       [XCenter,YCenter,ZCenter]= ...
%           CORNER2CENTER(XCorner,YCorner,ZCorner)
%
%       See also: CONV, CONV2, CONVN

if (nargin==0),
  if (nargout>0),
    error('Too many output arguments.');
  else,
    varargout={};
    return;
  end;
else, % nargin>0
  nINP=nargin;
  ch=logical(zeros(1,length(varargin)));
  for i=1:length(varargin),
    ch(i)=ischar(varargin{i}) & ndims(varargin{i})==2 ...
                              & size(varargin{i},1)==1;
  end;
  INP=varargin(~ch);
  nINP=length(INP);
  opt=varargin(ch);
  if (nINP>1) & (nargout<nINP),
    error('Not enough output arguments.');
  elseif (nargout>nINP),
    error('Too many output arguments.');
  end;
end;

method='mean';
same=0;
for i=1:length(opt),
  switch lower(opt{i}),
  case {'s','sa','sam','same'},
    same=1;
  case {'ma','max'},
     method='max';
  case {'mi','min'},
     method='min';
  case {'me','mea','mean'},
     method='mean';
  otherwise,
     error(sprintf('Invalid option: %s',opt));
  end;
end;
varargout=cell(1,nargout);

for a=1:nINP, % for each argument
  if iscell(INP{a}),
    varargout{a}=cell(size(INP{a}));
    [varargout{a}{:}]=corner2center(opt{:},INP{a}{:});
  else
    CC=ones(repmat(2,1,ndims(INP{a})));
    CC=CC/sum(CC(:));
    switch method,
    case 'mean',
      tmp=convn(INP{a},CC,'valid');
    otherwise,
      error('Method not yet implemented.');
    end;
    if same,
      varargout{a}=repmat(NaN,size(INP{a}));
      for d=1:ndims(INP{a}),
        ind{d}=2:size(INP{a},d);
      end;
      varargout{a}(ind{:})=tmp;
    else,
      varargout{a}=tmp;
    end;
  end;
end;
