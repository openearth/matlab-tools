function [xo,yo,po,mo,to,lo]=int_lntri(xi,yi,TRI,X,Y)
%INT_LNTRI Intersection of line and triangular mesh.
%   [XCROSS,YCROSS] = INT_LNTRI(XLINE,YLINE,TRI,X,Y)
%   Computes the points where the line (XLINE,YLINE)
%   crosses edges of a triangular mesh (TRI,X,Y).
%
%   [XCROSS,YCROSS,IND,WGHT] = ...
%   Returns also indices IND and weights WGHT to compute values at the
%   points XCROSS and YCROSS using linear interpolation of values V at X,Y
%   using VCROSS = SUM(V(IND).*WGHT,2).
%
%   [XCROSS,YCROSS,IND,WGHT,INDTRI] = ...
%   Returns also the numbers INDTRI of the triangles in which each line
%   segment between crossings is located. INDTRI will be NaN for all line
%   segments that lie outside all triangles.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
