function varargout=xyveloc(varargin)
%XYVELOC Reads X,Y,U,V from a trim- or com-file.
%   [U,V]=XYVELOC(NFStruct,TimeStep)
%   Reads the velocity field at the specified timestep from
%   the specified NEFIS file. By default TimeStep is the last
%   field of the CURTIM or map-series group. The default NEFIS
%   file is the last opened NEFIS file.
%
%   [X,Y,U,V]=XYVELOC(NFStruct,TimeStep)
%   Reads also the coordinates of the gridpoints at which the
%   velocities are given (waterlevel points).
%
%   [U,V,W]=XYVELOC(NFStruct,Index)
%   Reads a 3D velocity field.
%
%   [X,Y,Z,U,V,W]=XYVELOC(NFStruct,Index)
%   Reads the 3D velocity field and returns the 3D coordinates
%   of the velocity values.
%
%   [...]=XYVELOC(...,'option')
%   where option equals:
%   * total, fluc, mean
%     Reads the total velocity, fluctuation component, or mean
%     velocity field in case of a HLES simulation. (trim-file,
%     2D only).
%     Default seting is 'total'.
%   * vort
%     Computes the z-component of the vorticity:
%     Vort=XYVELOC(...,'vort')
%
%   See also VS_USE, VS_GET, VS_LET.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
