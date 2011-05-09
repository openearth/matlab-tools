function handle=qp_colorbar(varargin)
%QP_COLORBAR Display color bar (color scale).
%   QP_COLORBAR mixes functionality of the COLORBAR functions in
%   MATLAB 5.3 and MATLAB 6.5. It does not change the settings of
%   the current figure and current axes. It does not make the
%   figure visible in compiled mode. It allows only one colorbar
%   per axes (either vertical or horizontal) and switches upon
%   request between them. Can also remove the colorbar.
%
%   QP_COLORBAR(LOC) where LOC='horiz','vert','none' or axes handle.
%   ...,'peer',AX) links to axes object AX.
%
%   Derived from COLORBAR by Clay M. Thompson 10-9-92, The MathWorks, Inc.

%   If called with COLORBAR(H) or for an existing colorbar, don't change
%   the NextPlot property.

%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
