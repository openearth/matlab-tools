function [Classified,ClassBoundaries]=cont2class(Continuous,Classes,NoC),
% CONT2CLASS segments a continuous value dataset into classes
%       Classified=CONT2CLASS(Continuous,ClassBoundaries)
%       Classified=CONT2CLASS(Continuous,'N',NumberOfClasses)
%       uses NumberOfClasses classes of equal width between
%       min(Continuous) and max(Continuous). The first and last
%       classes are extended to minus and plus infinity.
%
%       [Classified,ClassBoundaries]=CONT2CLASS(...)
%       returns the class boundaries as the second output argument.

% (c) 1998, H.R.A.Jagers, University of Twente, WL|delft hydraulics

if nargin<2,
  error('Not enough input arguments'),
else,
  if ~isnumeric(Continuous),
    error('First argument should be a numeric matrix.');
  end;
  if ischar(Classes), % 'N'
    if nargin<3,
      error('Third argument required.');
    end;
    Min=min(Continuous(:));
    Max=max(Continuous(:));
    LowerClassBoundary=[-Inf Min+(1:(NoC-1))*(Max-Min)/NoC];
  else,
    LowerClassBoundary=sort(Classes(:));
  end;
end;

Classified=zeros(size(Continuous));
for c=1:length(LowerClassBoundary),
  Classified=Classified+(Continuous>LowerClassBoundary(c));
end;

if nargout>1,
  ClassBoundaries=LowerClassBoundary;
end;