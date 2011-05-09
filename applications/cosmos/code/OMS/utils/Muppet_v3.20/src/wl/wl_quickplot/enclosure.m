function varargout=enclosure(cmd,varargin)
%ENCLOSURE Read/write enclosure files and convert enclosures.
%   ENCLOSURE provides support for enclosure operations in general, like
%   reading, writing and applying enclosures.
%
%   MN=ENCLOSURE('read',FILENAME) reads a Delft3D or WAQUA enclosure file.
%
%   ENCLOSURE('write',FILENAME,MN) writes a Delft3D enclosure file.
%
%   ENCLOSURE('write',FILENAME,MN,'waqua') writes a WAQUA enclosure file.
%
%   [X,Y]=ENCLOSURE('apply',MN,Xorg,Yorg) applies the enclosure, replacing
%   grid coordinates outside the enclosure by NaN.
%
%   MN=ENCLOSURE('extract',X,Y) extracts the enclosure indices from X and
%   Y matrices containing NaN for points outside the enclosure.
%
%   [XC,YC]=ENCLOSURE('coordinates',MN,X,Y) obtain the X,Y coordinates from
%   M,N enclosure indices. If the MN argument is skipped, the enclosure
%   indices will first be determined using the extract call above.
%
%   See also WLGRID.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
