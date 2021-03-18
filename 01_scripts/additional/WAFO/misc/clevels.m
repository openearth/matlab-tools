function [CL,c]=clevels(c)
%CLEVELS  Extract the contour levels from the contour matrix
% 
% CALL: [CL, c1] = clevels(C)
%
% CL = [level1 level2, ... ] vector of contour levels (like the one you
%                            give into CONTOUR when you want manual
%                            control of the contour levels).
% C1 = [NaN x1 x2 x3 ... NaN x1 x2 x3 ...;
%       NaN y1 y2 y3 ... NaN y1 y2 y3 ...]
%       contour matrix with levels and pairs set to NaN's.
% C  = [level1 x1 x2 x3 ... level2 x1 x2 x3 ...;
%       pairs1 y1 y2 y3 ... pairs2 y1 y2 y3 ...]
%      contour matrix as described in CONTOURC
%
% Example:
% 
% c = contour(peaks);
% [cl, c1] = clevels(c);
% plot(c1(1,:),c1(2,:));
% cltext(cl)
%
% See also  contourc, ecolorbar

% History
% revised pab dec 2003
% minor changes  
% revised pab 03.07.2001
% -changed name from levels to clevels
% - added sort and removal of duplicate levels by unique.
%Time-stamp:<Last updated on 00/06/30 at 14:32:43 by even@gfi.uib.no>
%File:<d:/home/matlab/levels.m>

% BEWARE: In the contour matrix from contourf there is a "fictious"
% contour level, max(max(data)), and it's given as a point. this is probably
% useful for functions using the contour matrix, as a color reference or
% something, but why is not the same done for min(min(data))? It has nothing
% to do with wich end of the scale occupies most of the area, it's always in
% the max-end. 
%
% Anyway, CLEVELS does not extract this bogus "contourlevel".


error(nargchk(1,1,nargin));
limit = size(c,2);
i=1;j=1;
while (i <= limit) 
  CL(j)  = c(1,i);
  pairs  = c(2,i);
  c(:,i) = NaN;
  i      = i+pairs+1;
%  if j==1 | cont(j)~=cont(j-1)
  j=j+1; 
%  end
end

% remove the bogus level in the end of c
%CL=CL(1:length(CL)-1); 
% sort and remove duplicate levels
CL = unique(CL); 


