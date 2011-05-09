function lim=limits(ax,limtype);
%LIMITS Determine real x,y,z,c limits.
%   Lim=LIMITS(Axes,LimType)
%   returns the real limits of the objects
%   contained in the axes object, where LimType
%   can be 'clim','xlim','ylim' or 'zlim'.
%
%   Lim=LIMITS(Handles,LimType)
%   returns the real limits based on only the
%   specified objects.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
