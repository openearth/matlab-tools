function trim2rst(trim,i,rst)
%TRIM2RST Extract Delft3D-FLOW restart file from TRIM-file.
%
%   TRIM2RST(TRIMFILE,i,ResartFilename)
%   Read data for time step i from TRIM-file and write
%   data to specified Delft3D-FLOW restart file. The
%   TRIM-file can be specified by means of its name or
%   data structure obtained from VS_USE.
%
%   TRIM2RST(timestep,TRIRSTFILE)
%   Use the last opened nefis file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
