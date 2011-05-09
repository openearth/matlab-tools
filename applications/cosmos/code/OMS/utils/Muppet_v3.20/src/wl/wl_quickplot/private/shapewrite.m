function shapewrite(filename,varargin)
%SHAPEWRITE Write ESRI shape files.
%   SHAPEWRITE(filename,XYCell)
%   Write patches to shape file (.shp,.shx,.dbf).
%   XYCell should be a cell array of which each
%   element is a Nix2 array defining the polygon
%   consisting of Ni points (X,Y) co-ordinates.
%   The polygons will be closed automatically if
%   they are open.
%
%   Alternatively use:
%   SHAPEWRITE(filename,XY,Patches)
%   with XY a Nx2 matrix of X and Y co-ordinates
%   and Patches a matrix of point indices: each
%   row of the matrix represents one polygon. All
%   polygons contain the same number of points.
%
%   SHAPEWRITE(...,Values)
%   SHAPEWRITE(...,ValLabels,Values)
%   Write data associated with the polygons to the
%   dBase file. Values should be a NPxM matrix where
%   NP equals the number of polygons and M is the
%   number of values per polygon. The default data
%   labels are 'Val_1', 'Val_2', etc. Use a cell
%   array ValLabels if you want other labels. The
%   label length is restricted to a maximum of 10
%   characters.
%
%   SHAPEWRITE(filename,'polyline', ...)
%   Write polylines instead of polygons.
%   SHAPEWRITE(filename,'polygon', ...)
%   Write polygons (i.e. default setting).
%
%   SHAPEWRITE(filename,'point',XY)
%   Write points instead of polygons. XY should be a
%   NPx2 matrix. The number of rows in the optional
%   Value array should match the number of points.
%
%   See also SHAPE, DBASE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
