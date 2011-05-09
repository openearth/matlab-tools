function xx_logo(logoname,ax,varargin)
%XX_LOGO Plot a logo in an existing coordinate system.
%   XX_LOGO('LogoID',Axes)
%   Converts the Axes into a logo. Supported LogoIDs
%   are:
%     'wl' or 'dh' for WL | Delft Hydraulics
%     'ut'         for University of Twente
%     'deltares'   for Deltares
%
%   XX_LOGO('LogoID',Axes,Pos)
%   where Pos is a 1x4 matrix: the position in the
%   Axes where the logo should be plotted.
%   where Pos is a 1x5 matrix: the position and
%   rotation of the logo in the Axes object. The
%   rotation should be specified in radians.
%
%   ...,LineWidth,EdgeColor,FaceColor)
%   specify non default line width, edge and face colors for Twente logo.
%   ...,LineWidth,EdgeColor,FaceColor1,FaceColor2)
%   specify non default line width, edge and two face colors for Deltares
%   logos. If the second face color is not specified, it is taken equal to
%   the first. The Deltares logo defaults to its standard colors, whereas
%   the Delft Hydraulics logo defaults to a transparent logo.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
