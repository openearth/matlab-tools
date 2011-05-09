function out=num2range(range);
% NUM2RANGE create spreadsheet range
%      RANGE=NUM2RANGE(COLROW)
%      Converts the specified row and column indices into
%      a spreadsheet range (string). The indices should be
%      ordered as left column, upper row, right column,
%      lower row. This order corresponds with the default
%      order of specifying a spreadsheet range: upper-left:
%      lower-right. The range limits are reordered when
%      appropriate.
%
%      Examples:
%
%      num2range([2 2 4 30])
%      % returns 'B2:D30'
%      % so does num2range([4 30 2 2])
%      range2num([6 32])
%      % returns 'F32'

% Copyright (c) 2002, H.R.A. Jagers

if nargin<1,
  error('Not enough input arguments.')
end;

if length(range)==4
  cl=sort(range([1 3]));
  rw=sort(range([2 4]));
  out=[collabel(cl(1)) num2str(rw(1)) ':' collabel(cl(2)) num2str(rw(2))];
elseif length(range)==2
  out=[collabel(range(1)) num2str(range(2))];
else
  error('Invalid input range.');
end