function s=index(x,ind1,ind2)
% INDEX passes only indicated range of x
%     SUB=INDEX(FULL,I,J) returns SUB=FULL(I,J).
%       Any indices I and J resulting in an out of
%       range of the matrix FULL are ignored.
%     SUB=INDEX(FULL,I) returns SUB=FULL(I)
%       Any index I resulting in an out of range of the
%       vector FULL are ignored. If FULL is a matrix
%       the elements are adressed columnwise.
%     SUB=INDEX(FULL,C) with C a cell array of length
%       equal to the number of dimensions of FULL
%       returns if C={I J K L ...} SUB=FULL(I,J,K,L,...).
%
%     If FULL is a cell array the functions return the
%     cell equivalent of the results specified above, i.e.
%     with parenthesis substituted by braces
%       SUB=FULL{I,J,K,L,...}.
%
%     See also ROW, COLUMN

%     Copyright (c)  H.R.A. Jagers  12-05-1996

if nargin>3,
  fprintf(1,' * Too many input arguments\n');
elseif nargin==3,
  sx=size(x);
  if length(sx)==2,
    ind1=ind1(find( (ind1<=sx(1)) & (ind1>=1) ));
    ind2=ind2(find( (ind2<=sx(2)) & (ind2>=1) ));
    s=x(ind1,ind2);
    if iscell(x),
      s=x{ind1,ind2};
    else,
      s=x(ind1,ind2);
    end;
  else,
    fprintf(1,' * First argument is not a matrix.\n');
  end;
elseif nargin==2,
  if isempty(ind1) | isstruct(ind1),
    Str=['x' ref2str(ind1)];
    lasterr('');
    s=eval(Str,'[]');
    StrE=lasterr;
    if ~isempty(StrE),
      StrE=multiline(StrE);
      fprintf(1,'When evaluating: %s',Str);
      error(StrE(size(StrE,1),:));
    end;
  elseif iscell(ind1),
%    if ((min(size(x))==1) & (length(ind1)==1)) ...
%       | ((min(size(x))>1) & (ndims(ind1)==length(size(x))),
      Str='x(';
      for k=1:length(ind1),
        if strcmp(ind1{k},':'),
          ind1{k}=1:size(x,k);
        else,
          ind1{k}=ind1{k}(find( (ind1{k}<=size(x,k)) & (ind1{k}>=1) ));
        end;
        if k>1,
          Str=[Str ','];
        end;
        Str=[Str '[' sprintf('%i ',ind1{k}) ']'];
      end;
      Str=[Str,')'];
      lasterr('');
      s=eval(Str,'[]');
      StrE=lasterr;
      if ~isempty(StrE),
        StrE=multiline(StrE);
        fprintf(1,'When evaluating: %s',Str);
        error(StrE(size(StrE,1),:));
      end;
%    else,
%      fprintf(1,' * Number of dimensions of first argument and length of\n   second argument do not match.\n');
%    end;
  else,
    sx=size(x);
    ind1=ind1(find( (ind1<=sx(1)*sx(2)) & (ind1>=1) ));
    if iscell(x),
      s=x{ind1};
    else,
      s=x(ind1);
    end;
  end;
else
  fprintf(1,' * Too few input arguments\n');
end;