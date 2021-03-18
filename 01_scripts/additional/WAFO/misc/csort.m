function [b,I] = csort(a,amin,amax,chk)
%CSORT Counting sorting
%
% CALL [b,I] = csort(a,amin,amax)
%
% b    = sorted vector 
% I    = index vector defined by b = a(I);
% a    = vector of integers to sort (length N).
% amin = minimum value of a (default min(a)).
% amax = maximum value of a (default max(a)).
% 
% CSORT assumes that each of the N input elements is an integer. Let K
% denote the range of the integers. When K = O(N) the sorting
% runs in O(N) time.
% 
% Example: % Compare csort and sort
%  N = 50000;
%  a = floor(rand(N,1)*N/2)+1;
%  tic,[b,I] = csort(a,1,floor(N/2)+1);toc
%  tic,[b1,I1] = sort(a);toc
%
% See also  sort, histc


%Tested on: matlab 5.3
% History:
% by pab 15.08.2001


error(nargchk(1,4,nargin))
disp('This function is only available as a mex-compiled function.')
error('Compile csort.c by using mex -O csort.c and try again.')

