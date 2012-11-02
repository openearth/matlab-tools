function [theta,diff_theta] = real2interval(x,minima,maxima)
%INTERVAL2REAL   Mappping that goes from the real line to [a,b].
%
%   For vectors, REAL2INTERVAL(X,A,B) maps the real value X to value THETA
%   element of the interval [a,b]. A and B are vectors that specify the
%   minima and the maxima respectively. X, A, B must have the same size.
%
%   [THETA,DIFF_THETA] = REAL2INTERVAL(X,A,B), where DIFF_THETA is the
%   derivative of the transformation, evaluated at point X.
%
%   See also INTERVAL2REAL

    theta = (minima+(maxima-minima).*exp(-exp(x))); % min <stateVector< max
    diff_theta = -(maxima-minima).*exp(-exp(x)+x);

end
