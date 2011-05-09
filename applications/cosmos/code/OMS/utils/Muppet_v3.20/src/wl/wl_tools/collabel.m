function label=collabel(i);
% COLLABEL generates the label of a column
%      as used by spreadsheets, i.e. A-Z,AA-AZ,BA-BZ, etc.

% Copyright (c) H.R.A. Jagers

if nargin~=1,
  fprintf(1,'* exactly one input argument expected');
  return;
end;

% if i is a matrix it must be a column vector
if min(size(i,2),size(i,1))~=1,
  fprintf(1,'* input argument must be a scalar or vector');
  return;
end;

if (size(i,2)>size(i,1)),
  i=i';
end;

label=[];
first=1;
while any(i~=0),
  j=i-26*fix((i-1)/26);
  j=j+32+(i~=0)*32;
  i=fix((i-1)/26);
  label=[j label];
  first=0;
end;
label=char(label);