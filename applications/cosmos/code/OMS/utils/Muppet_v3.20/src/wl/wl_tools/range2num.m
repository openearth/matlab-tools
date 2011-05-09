function [out1,out2]=range2num(label,option);
% RANGE2NUM interpret spreadsheet range
%      ROWCOL=RANGE2NUM(RANGE)
%      Converts the specified spreadsheet range (string)
%      into row and column indices. The indices are ordered
%      as left column, upper row, right column, lower row.
%      This order corresponds with the default order of
%      specifying a spreadsheet range: upper-left:lower-right.
%      The range limits are reordered when appropriate.
%      Valid range separators are: double dot (..), minus (-),
%      colon (:). If the upper left corner is not specified
%      it defaults to A1.
%
%      Examples:
%
%      range2num('B2..D30')
%      % returns [2 2 4 30]
%      range2num('F2-B20')
%      % returns [2 2 6 20] (equals 'B2-F20')
%      range2num('F32')
%      % returns [6 32 6 32] (equals 'F32:F32')
%      range2num('-F32')
%      % returns [1 1 6 32] (equals 'A1:F32')
%      
%      [UPPLFT,LOWRGT]=RANGE2NUM(RANGE,'split')
%      does not convert to numerical indices but splits
%      into coordinates for upper left and lower right
%      corners (includes necessary reordering and expansion).

% Copyright (c) 2000, H.R.A. Jagers

split=0;
if nargin<1,
  error('Not enough input arguments.')
elseif nargin==2,
  if ischar(option) & strcmp(lower(option),'split'),
    split=1;
  else,
    warning('Unknown second argument. Ignoring...');
  end;
end;

label=[upper(label) ' '];
rowcol=[0 0 0 0];
if isempty(deblank(label)),
  error('Empty range string.')
end;
[C1,rowcol(1),rowcol(2),label]=scanrowcol(label,1);

if isempty(deblank(label)),
  rowcol(3:4)=rowcol(1:2);
  C2=C1;
else,
  [Col,N,Err,nxt] = sscanf(label,' %[-:.]');
  if N~=1,
    error('Invalid format')
  end;
  label=label(nxt:end);

  [C2,rowcol(3),rowcol(4),label]=scanrowcol(label,1);
end;

if ~isempty(deblank(label)),
  error('Invalid format')
end;

if rowcol(3)<rowcol(1),
  rowcol([1 3])=rowcol([3 1]);
  C=C1;
  C1=C2;
  C2=C;
end;
if rowcol(4)<rowcol(2),
  rowcol([2 4])=rowcol([4 2]);
end;

if split,
  out1=sprintf('%s%d',C1,rowcol(2));
  out2=sprintf('%s%d',C2,rowcol(4));
else,
  out1=rowcol;
end;


function [C1,col,row,remainder]=scanrowcol(label,canskip),
[C1,N,Err,nxt] = sscanf(label,' $%[A-Z]');
if N==0,
  [C1,N,Err,nxt] = sscanf(label,' %[A-Z]');
end;
if (N==0) & canskip,
  C1='A';
  col=1;
  row=1;
  remainder=label;
else,
  col=col2num(C1);
  [row,N,Err,nxt2] = sscanf(label(nxt:end),' $%i');
  if N==0,
    [row,N,Err,nxt2] = sscanf(label(nxt:end),' %i');
  end;
  if N>1,
    error('Invalid format')
  end;
  nxt=nxt+nxt2-1;
  remainder=label(nxt:end);
end


function N=col2num(Col);
N=transpose(abs(Col(end:-1:1)-64));
N=N.*(26.^(0:length(Col)-1)');
N=sum(N);