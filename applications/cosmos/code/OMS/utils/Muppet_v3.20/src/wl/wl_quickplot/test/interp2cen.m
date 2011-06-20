function X=interp2cen(varargin)
%INTERP2CEN Interpolate to center.
%      X=INTERP2CEN(x)
%      Interpolates data from cell corners to centers (NM dirs).
%      x is a N x M matrix
%
%      X=INTERP2CEN(x,flag)
%      Interpolates data from cell corners to centers (NM dirs).
%      x is a nTim x N x M x ... matrix

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
