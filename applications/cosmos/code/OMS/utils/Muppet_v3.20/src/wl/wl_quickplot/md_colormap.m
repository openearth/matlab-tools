function cmap=md_colormap(varargin)
%MD_COLORMAP Colour map editor.
%    MD_COLORMAP(CMAPOBJ) starts an interactive colormap editor to edit the
%    specified colormap. By default the editor starts with the colormap
%    JET.
%
%    CMAPOBJ = MD_COLORMAP(...) returns a structure containing the edited
%    colormap. Use the CLRMAP command to convert the structure to a
%    standard MATLAB colormap array.
%
%    See also CLRMAP.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
