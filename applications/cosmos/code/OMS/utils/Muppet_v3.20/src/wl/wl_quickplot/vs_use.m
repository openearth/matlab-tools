function VSout=vs_use(varargin)
%VS_USE Initiates the use of a NEFIS file.
%   NFStruct=VS_USE('filename') scan the file and return a VS structure
%   containing important metadata of the NEFIS file that is being opened.
%   The contents of NFStruct is used by other routines to access the real
%   data in the file.
%
%   NFStruct=VS_USE(...,'quiet') read the specified file without showing a
%   wait bar.
%
%   NFStruct=VS_USE(...,'debug') write a debug information to a file while
%   scanning the file.
%
%   See also QPFOPEN, QPREAD, VS_DISP, VS_GET, VS_LET, VS_DIFF, VS_FIND,
%      VS_TYPE.

%   OBSOLETE
%   ========
%   VS_USE scans the structure of the definition and data files, this
%   will take some time. To circumvent having to determine the structure
%   after each restart of MATLAB, VS_USE allows you to store the data in a
%   file with the same name base (as indicated by 'filename') and extention
%   .mat; and reuse this info when the file is reopened later. This used to
%   be the default behaviour but is now optional: use option 'usemat'. The
%   old option 'nomat' is still accepted and overrules 'usemat'. If changes
%   were made to the .def and/or .dat files, one should add 'refresh' as
%   additional argument to prevent reading an existing mat-file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
