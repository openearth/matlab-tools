function dataOut = vmean(dataIn,varargin)
%VMEAN Compute average of data in vertical direction.
%   DATA2D = VMEAN(DATA3D,METHOD) averages the data of a 3D data set
%   obtained from QPREAD over the vertical direction. The averaging method
%   should be 'linear' (default) or 'squared'.
%
%   Example 1
%      %depth average
%      quantities = qpread(FI);
%      ivel = strmatch(quantities,'velocity');
%      Qvel = quantities(ivel);
%      sz = qpread(FI,Qvel,'size');
%      data3d = qpread(FI,Qvel,'griddata',t);
%      data2d = vmean(data3d);
%
%   Example 2
%      %average of certain vertical range
%      sub3d  = vrange(data3d,-3,-2);
%      sub2d  = vmean(sub3d);
%
%   See also QPFOPEN, QPREAD, VRANGE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
