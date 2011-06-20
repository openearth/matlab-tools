function varargout=corner2center(varargin),
%CORNER2CENTER Interpolate data from cell corners to cell centers.
%   Interpolates coordinates/data from corners (DP) to
%   centers (S1). Supports 1D, 2D, and 3D data, single
%   block and multiblock. In case the output datasets should
%   have the same size as the input datasets, add the optional
%   argument 'same' to the input arguments.
%
%   XCenter=CORNER2CENTER(XCorner)
%   [XCenter,YCenter,ZCenter]= ...
%       CORNER2CENTER(XCorner,YCorner,ZCorner)
%
%   See also CONV, CONV2, CONVN.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
