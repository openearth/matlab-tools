function Locations = addlocation(Locations,Name,Topology,Dimensions, ...
    TimeDimensions,Group,XCoord,YCoord,ZCoords)
%ADDLOCATION Add a location to a location list.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Define name

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
