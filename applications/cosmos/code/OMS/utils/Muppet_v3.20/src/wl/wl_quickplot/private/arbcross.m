function [varargout]=arbcross(varargin)
%ARBCROSS Arbitrary cross-section through grid.
%   [X,Y,V1,V2, ...]=ARBCROSS(TRI,XTRI,YTRI,VTRI1,VTRI2, ... ,XB,YB)
%   Intersects a triangular mesh defined by TRI, XTRI and YTRI with an
%   arbitrary line defined by base points XB, YB. The output vectors X
%   and Y contain the co-ordinates at which the line crosses the grid
%   lines of the mesh. The vector Vi contains interpolated values at
%   these locations given the values VTRIi at the mesh points.
%
%   [X,Y,V1,V2, ...]=ARBCROSS(XGRID,YGRID,VGRID1,VGRID2, ... ,XB,YB)
%   Intersects a curvilinear mesh defined by XGRID and YGRID with an
%   arbitrary line.
%
%   Computing the locations of the intersections of the mesh and the line
%   can take a significant amount of time. It can be more efficient to
%   compute these intersections and the associated coefficients for the
%   interpolation only once. The necessary intermediate information can
%   be stored in a structure by using the following syntax:
%   STRUCT=ARBCROSS(TRI,XTRI,YTRI,XB,YB)
%   [X,Y,STRUCT]=ARBCROSS(TRI,XTRI,YTRI,XB,YB)
%   STRUCT=ARBCROSS(XGRID,YGRID,XB,YB)
%   [X,Y,STRUCT]=ARBCROSS(XGRID,YGRID,XB,YB)
%
%   Subsequently, the interpolation of data to that line can be carried
%   out efficiently by providing the structure as a first argument
%   instead of the original coordinates:
%   [V1,V2, ...] = ARBCROSS(STRUCT,VGRID1,VGRID2, ...)
%   [X,Y,V1,V2, ...] = ARBCROSS(STRUCT,VGRID1,VGRID2, ...)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
