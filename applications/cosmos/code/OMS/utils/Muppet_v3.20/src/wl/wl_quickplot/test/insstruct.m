function Out=insstruct(Base,i,Ins)
%INSSTRUCT Insert array.
%   In compiled mode the following line
%     Out=[Out(1:i-1);Ins;Out(i+1:end)];
%   gives the error
%     ERROR: CAT arguments are not consistent in structure field number.
%   if i==length(Out).
%   This routine is a workaround.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
