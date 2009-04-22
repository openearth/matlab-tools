function out = iscolor(in)
%ISCOLOR  check whether is color (rgb triplet or matlab lettercode as 'r')
%
% out = iscolor(in)
% returns true when one of
% * 'r','g','b','c','y','m','k' or 'w'
% or
% * rgb triplet (checkes for size and values)
%
%See also: 

% G.J. de Boer, March 7 2006

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = false;

if ischar(in)
   if ~isempty(strfind('rgbcymkw',in))
      out = true;
   end
elseif isnumeric(in)
   sz = size(in);
   %% check for size to be [1 3] or [3 1]
      %% ----------------------
   if max(sz)==3 & ...
      min(sz)==1
      %% check for values to be within [0,1]
      %% ----------------------
      if all((in<=1) & (in>=0))
         out = true;
      end
   end
end

% EOF