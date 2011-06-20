function classbar(ax,Th,varargin)
%CLASSBAR Converts a color bar into a classbar.
%   CLASSBAR(ColorbarHandle,Thresholds,NumberFormat)
%   converts the specified colorbar into a class bar
%   using the specified number format (default %1.4g)
%
%   CLASSBAR(ColorbarHandle,Thresholds,CellString)
%   converts the specified colorbar into a class bar
%   with the labels specified in the cell string.
%
%   ...,'labelcolor')
%   labels the colors instead of the transitions. The
%   colors should be labeled in case of a CONTOUR plot,
%   the transitions should be labeled in case of a
%   CONTOURF plot.
%
%   ...,'plotall')
%   makes sure that all classes are drawn irrespective
%   of the classes used in the plot. This includes the
%   last class >= maximum threshold.
%
%   ...,'plot',N)
%   makes sure that the first N classes are drawn irrespective
%   of the classes used in the plot. If N>=length(Thresholds)
%   this implies 'plotall'.
%
%   ...,'plotrange',[N1 N2])
%   plots only the classes in the range N1:N2.
%
%   ...,'label',ThresholdsVal)
%   uses the value in the ThresholdsVal vector to display
%   along the class bar. NaN values will not be labelled.
%
%   ...,'format',FormatString)
%   uses the specified format to label the classbar,
%   for instance '%3.2f'.
%
%   ...,'max')
%   use this option if cdata of contour patches contain
%   maximum instead of minimum values.
%
%   Example 1
%       thr=.25:.1:.95;
%       contourf(rand(10),thr)
%       axis square
%       classbar(colorbar('horz'),thr)
%
%   Example 2
%       r=rand(10)-0.5;
%       thr=[min(r(:)) -0.1 0.1];
%       contourf(r,thr)
%       h=colorbar;
%       classbar(h,thr,{'negative','approx.zero','positive'},'labelcolor')
%
%   See also CONTOURF, COLORBAR.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
