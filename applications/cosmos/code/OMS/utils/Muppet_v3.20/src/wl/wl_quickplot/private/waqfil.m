function S = waqfil(cmd,file,varargin)
%WAQFIL Read various Delwaq files.
%
%   FI = WAQFIL('open',FILENAME,...extra arguments...)
%   Opens the specified file and reads a part or all of the
%   data.
%
%   Data = WAQFIL('read',FI,...extra arguments...)
%   Reads additional data from the file.
%
%   This function call supports the following file types
%   (the extra arguments for the open call are indicated
%   after the list of file name extensions).
%
%   Volume, salinity, temperature, and shear stress files
%     * .vol, .sal, .tem, .vdf, .tau files: NSeg
%
%   Segment function files
%     * .segfun files                     : NSeg, NPar
%
%   Flow area and flux files
%     * .are, .flo files                  : NExch
%
%   Pointer table files
%     * .poi files                        : NExch
%
%   Distance table files
%     * .len files                        : NExch
%
%   Chezy files
%     * .chz files                        : -
%
%   Segment surface area files
%     * .srf files                        : -
%
%   table files
%     * .lgt files                        : -

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
