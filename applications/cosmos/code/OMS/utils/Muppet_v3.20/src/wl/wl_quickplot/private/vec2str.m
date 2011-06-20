function Str=vec2str(OrigVec,varargin);
%VEC2STR Creates a string of a row vector.
%
%   S=VEC2STR(V)
%   Converts the rows vector V into a string representation S.
%   The string will contain opening and closing brackets.
%   Depending on the data the string may also contain the colon
%   operator, and the ones and zeros function calls.
%
%   ...,'nobrackets')
%   Prevents the output of the opening and closing brackets.
%
%   ...,'noones')
%   Prevents the output of ones and zeros function calls.
%
%   Example
%      Str=vec2str([1 2 3 4 5 6 7 -1 -1 -1 -1 -1 NaN inf inf inf])
%      % returns '[ 1:7 -1*ones(1,5) NaN Inf Inf Inf ]'

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
