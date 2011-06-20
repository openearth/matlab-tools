function dataOut = hslice(dataIn,Z0)
%HSLICE Horizontal data slice of 3D data set.
%   DATA2D = HSLICE(DATA3D,Z0) extracts a horizontal data slice out of a 3D
%   data set obtained from QPREAD at the specified level Z0. HSLICE
%   supports both data at grid points ('gridddata') and at cell centres
%   ('gridcelldata') as provided by QPREAD. The output of HSLICE is data
%   structure compatible with the QPREAD output.
%
%   Example
%      quantities = qpread(FI);
%      ivel = strmatch(quantities,'velocity');
%      Qvel = quantities(ivel);
%      sz = qpread(FI,Qvel,'size');
%      for t = 1:sz(2); %select time step where 1<=t<=sz(2)
%         data3d = qpread(FI,Qvel,'griddata',t);
%         data2d = hslice(data3d,-3);
%         quiver(data2d.X,data2d.Y,data2d.XComp,data2d.YComp)
%         drawnow
%      end
%
%   See also QPFOPEN, QPREAD, VRANGE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
