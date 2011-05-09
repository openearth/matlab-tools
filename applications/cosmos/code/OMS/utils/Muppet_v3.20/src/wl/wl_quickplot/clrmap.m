function outmap=clrmap(S,m,Swrite)
%CLRMAP Creates a colormap based on a few colors.
%   CLRMAP(COLORS,M) sets the colormap of the current figure to a Mx3
%   colormap based on the Kx3 array of RGB triplets given by COLORS; the
%   K colors appear at equal distances in the colormap. If M is dropped,
%   the same length as the current figure's colormap is use. If no figure
%   exists, MATLAB creates one.
%
%   CLRMAP(CMAPOBJ,M) sets the colormap of the current figure to a Mx3
%   colormap based on the specified colormap object. CMAPOBJ is a structure
%   of a colormap that may be obtained from MD_COLORMAP or read from file.
%
%   CLRMAP(FILENAME,M) sets the colormap of the current figure to a Mx3
%   colormap based on the colormap file.
%
%   MAP = CLRMAP(...) returns the colormap instead of updating the colormap
%   of the current figure.
%
%   CMAPOBJ = CLRMAP(COLORS,NAME) converts the array of RGB-color triplets
%   into a colormap object and labels it with the given name.
%
%   CLRMAP('write',FILENAME,CMAPOBJ) writes the colormap object to the
%   specified file.
%
%   CMAPOBJ = CLRMAP('read',FILENAME) reads the colormap object from the
%   specified file.
%
%   Example
%      Create, edit and apply colormap.
%      CMAPOBJ = clrmap([1 0 0;0 0 0;0 0 1],'red-white-blue');
%      CMAPOBJ = md_colormap(CMAPOBJ)
%      clrmap(CMAPOBJ)
%
%   See also MD_COLORMAP.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
