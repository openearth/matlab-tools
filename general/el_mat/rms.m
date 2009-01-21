function y = rms(x)
%RMS	Root mean square.
%	For vectors, RMS(x) returns the root mean square.
%	For matrices, RMS(X) is a row vector containing the
%	root mean square of each column.
%
%See also: MEAN, MAX, MIN, STD

    y = sqrt(mean(x.^2));
   %y = sqrt( sum(x.^2)/length(x));
