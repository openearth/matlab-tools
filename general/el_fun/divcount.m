function divcount = divcount(x,y)
%DIVCOUNT
% divcount = divcount(x,y)
%
% divcount = div(x-1,y)+1;
%
% Useful together with remcount to determine
% position in a rectangular grid.
%
%  x         1  2  3  4  5  6  7  8  9 10 11 12
%
%  rem       1  2  0  1  2  0  1  2  0  1  2  0
%  mod       1  2  0  1  2  0  1  2  0  1  2  0
%  div       0  0  1  1  1  2  2  2  3  3  3  4
%
%  remcount  1  2  3  1  2  3  1  2  3  1  2  3
%  divcount  1  1  1  2  2  2  3  3  3  4  4  4 
%
% SEE ALSO: rem, mod, div, remcount, divcount

% G.J. de Boer, March 2005

% divcount = floor((x - remcount(x,y))./y)+1;

  divcount = div(x-1,y)+1;

