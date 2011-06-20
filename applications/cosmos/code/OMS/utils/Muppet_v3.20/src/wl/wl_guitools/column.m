function s=column(x,j)
% COLUMN passes only indicated columns of x
%     SUB=COLUMN(FULL,J) returns SUB=FULL(:,J)
%     any indices J resulting in an out of range of the matrix FULL are ignored
%
%     See also ROW, INDEX

%     Copyright (c)  H.R.A. Jagers  12-05-1996

if nargin>2,
  fprintf(1,' * Too many input arguments\n');
elseif nargin==2,
  sx=size(x);
  j=j(find( (j<=sx(2)) & (j>=1) ));
  s=x(:,j);
else
  fprintf(1,' * Too few input arguments\n');
end;