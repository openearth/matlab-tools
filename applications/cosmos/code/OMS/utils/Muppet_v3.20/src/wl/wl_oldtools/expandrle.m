function Vector=expandrle(Value,NumOfTimes),
% EXPANDRLE expands a runlength encoding
%     Value = [1 3 5 2];  % amplitudes of Vector
%     NumOfTimes = [2 3 1 4]; % segment lengths of Vector
%     Vector=expandrle(Value,NumOfTimes);
%     Vector = [1 1 3 3 3 5 2 2 2 2]; % the vector created

% Doug Schwarz' solution:
%
% m = max(NumOfTimes);
% n = length(Value);
% Vector = sparse(zeros(m,n));
% Vector(sub2ind([m,n],NumOfTimes,1:n)) = NaN;
% Vector = cumsum([Value;Vector]);
% Vector = full(Vector(~isnan(Vector)).');

% my solution
% Doesn't work for NaNs, inf, -inf, and combinations like 1e-37 1e45
% nor for numbers that with NumOfTimes(i)=0
%
% Start=cumsum([1 NumOfTimes(1:(end-1))]);
% Vector=zeros(1,Start(end)+NumOfTimes(end)-1);
% Vector(1)=Value(1);
% Vector(Start(2:end))=diff(Value);
% Vector=cumsum(Vector);

% David Goodmanson's solution
%
NumOfTimesX = NumOfTimes(NumOfTimes>0);
ValueX =  Value(NumOfTimes>0);
if isempty(ValueX),
  Vector = [];
else,
  Index = zeros(1,sum(NumOfTimesX));
  Index(cumsum([1 NumOfTimesX(1:end-1)])) = 1;
  Vector = ValueX(cumsum(Index));
end;

% Peter Acklam's solution
%
% is called vecrep: http://www.math.uio.no/~jacklam/matlab/software/util/matutil/vecrep.m