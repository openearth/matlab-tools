function [Value,Freq]=countfreq(A);
% COUNTFREQ Set unique and frequency count.
%   COUNTFREQ(A) returns the unique values in A (sorted).
%   [V,F]=COUNTFREQ(A) returns also the number of times
%   that each value occurs in A.

if isnumeric(A),
  A=sort(A(:));                   % sort and convert to vector
  if size(A,2)>1,                 % make sure I get a column vector
    A=transpose(A);
  end;
  Unique=[];
else,
  [Unique,Dummy,A]=unique(A);     % find unique non-numeric values and
  A=sort(A);                      % use the J values returned for counting.
end;

[Freq,Dummy,Value]=find(diff(A)); % get value differences and cumulative frequencies
Value=cumsum([A(1);Value]);       % compute values from value differences
Freq=diff([0;Freq;length(A)]);    % compute frequencies from cumulative frequencies

if ~isempty(Unique),              % return the non-numeric values when appropriate
  Value=Unique;
end;