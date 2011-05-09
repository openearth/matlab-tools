function h = qp_colormap(MapName,M)
%QP_COLORMAP QuickPlot colormap repository.
%
%   CMap = QP_COLORMAP(MName,M)
%   returns an M-by-3 matrix containing colormap MName. The input argument
%   M is optional. If it is not provided the length of the colormap is
%   taken equal to the length of the colormap of the current figure.
%
%   CMapStruct = QP_COLORMAP(':getstruct',MName)
%   returns a structure of the indicated colormap which is compatible with
%   the CLRMAP function.
%
%   Maps = QP_COLORMAP
%   returns the names of all available maps on file, this list loaded upon
%   the first call of QP_COLORMAP.
%
%   Maps = QP_COLORMAP(':reload')
%   Forces reloading all colormaps from file and returns the new list.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
