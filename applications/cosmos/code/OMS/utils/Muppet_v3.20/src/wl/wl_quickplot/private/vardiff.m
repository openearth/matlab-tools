function out=vardiff(var1,var2,fid,formatflag,var1name,var2name)
%VARDIFF Determines the differences between two variables.
%   VARDIFF(var1,var2) lists the differences between the two
%   specified variables-files.
%
%   different=VARDIFF(var1,var2) returns the lowest appropriate
%   number in the following list
%     0   if the variables are identical (no NaNs found),
%     1   if the variables are identical (NaNs found),
%     2   if the variables are of different size, class or they are
%         structures with different fields.
%     2+N if the data is different in the Nth level, for matrices
%         this will be at most 3, for cell arrays and structures this
%         can become higher than 3. This basically indicates that you
%         need N subscripts to see the difference.
%   The function does not show the differences as text.
%
%   different=VARDIFF(var1,var2,fid) returns the number as described
%   above and writes the difference log to the file indicated by the
%   fid argument.
%
%   See also ISEQUAL.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
