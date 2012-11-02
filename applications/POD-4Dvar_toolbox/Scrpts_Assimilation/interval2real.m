function [x] = interval2real(theta,minima,maxima)
%INTERVAL2REAL   Mappping that goes from [a,b] to the real line.
%
%   For vectors, INTERVAL2REAL(THETA,A,B) maps the value THETA element of
%   [a,b] to the real line. A and B are vectors that specify the minima and
%   the maxima respectively. THETA, A, B must have the same size.
%
%   See also REAL2INTERVAL
    
    x = log(-log((theta-minima)./(maxima-minima)))';
end