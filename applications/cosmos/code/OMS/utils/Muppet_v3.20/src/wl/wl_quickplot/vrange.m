function dataOut = vrange(dataIn,Zmin,Zmax)
%VRANGE Selection of data based on a vertical coordinate range.
%   DATA3DOUT = VRANGE(DATA3DIN,ZMIN,ZMAX) extracts a horizontal data slice
%   located between vertical coordinates ZMIN and ZMAX out of a 3D data set
%   obtained from QPREAD. VRANGE supports both data at grid points
%   ('gridddata') and at cell centres ('gridcelldata') as provided by
%   QPREAD. The output of VRANGE is data structure compatible with the
%   QPREAD output.
%
%   Example
%      quantities = qpread(FI);
%      ivel = strmatch(quantities,'velocity');
%      Qvel = quantities(ivel);
%      sz = qpread(FI,Qvel,'size');
%      data3d = qpread(FI,Qvel,'griddata',t);
%      sub3d = vrange(data3d,-3,-2);
%
%   See also QPFOPEN, QPREAD, HSLICE, VMEAN.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
