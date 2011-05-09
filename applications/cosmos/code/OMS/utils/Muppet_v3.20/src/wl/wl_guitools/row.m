function s=row(x,i)
% ROW passes only indicated rows of x
%     SUB=ROW(FULL,I) returns SUB=FULL(I,:)
%     any indices I resulting in an out of range of the matrix FULL are ignored
%
%     See also COLUMN, INDEX

%     Copyright (c)  H.R.A. Jagers  12-05-1996

if nargin>2,
  fprintf(1,' * Too many input arguments\n');
elseif nargin==2,
  sx=size(x);
  i=i(find( (i<=sx(1)) & (i>=1) ));
  s=x(i,:);
else
  fprintf(1,' * Too few input arguments\n');
end;