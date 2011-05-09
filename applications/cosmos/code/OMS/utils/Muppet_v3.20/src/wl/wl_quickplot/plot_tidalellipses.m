function h = plot_tidalellipses(X,Y,argtype,varargin)
%PLOT_TIDALELLIPSES Plot tidal ellipses on a map.
%   PLOT_TIDALELLIPSES(X,Y,'AP',AMPU,PHIU,AMPV,PHIV) plots tidal ellipses
%   on a map at the X,Y locations based on the amplitudes and phases of the
%   two velocity components. The dimensions of X, Y, amplitude and phase
%   arrays should be identical. For the conversion of amplitudes and phases
%   into ellipse parameters the AP2EP routine is used.
%
%   PLOT_TIDALELLIPSES(X,Y,'EP',SEMA,ECC,INC,PHA) plots tidal ellipses
%   on a map at the X,Y locations based on the given by the semi-major
%   axes, eccentricity, inclination, and phase angles. The dimensions of
%   these six arrays should be identical.
%
%   H = PLOT_TIDALELLIPSES(...) returns a handle to the created line
%   object.
%
%   PLOT_TIDALELLIPSES(...,Prop1,Value1,Prop2,Value2,...) sets an
%   additional set of optional property values. Supported properties are:
%      'PlotType'    - sets the plot type of the tidal ellipse to
%
%            'cross'           - two axes of the ellipse
%            'ellipse'         - ellipse
%            'ellipsephase'    - ellipse with reference phase line and
%                                gap to indicate rotation direction.
%            'ellipsephasevec' - ellipse with reference phase line and
%                                vector to indicate rotation direction.
%
%      'PhaseOffset' - sets the phase offset for the reference phase
%                      indicator.
%      'Scale'       - scale factor: plots 1 m/s as specified map distance.
%                      The default scaling is automatic.
%      'Parent'      - sets the parent axes in which the ellipses will be
%                      plotted.
%      'Color'       - sets the line color.
%      'LineStyle'   - sets the line style.
%
%   See also TBA_PLOTELLIPSES, AP2EP.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
