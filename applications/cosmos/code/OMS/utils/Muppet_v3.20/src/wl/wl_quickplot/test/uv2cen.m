function [U,V]=uv2cen(u,v,kfu,kfv)
%UV2CEN Interpolate velocities.
%   [U,V]=UV2CEN(u,v)
%   Interpolates velocities from u and v points to zeta points
%   u and v are nTim x N x M x ... matrices
%
%   [U,V]=UV2CEN(u,v,kfu,kfv)
%   kfu and kfv are nTim x N x M matrices
%   (not yet implemented)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
