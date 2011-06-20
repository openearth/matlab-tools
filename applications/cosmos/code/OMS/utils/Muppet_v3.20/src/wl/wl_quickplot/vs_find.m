function Output=vs_find(FileData,IO_eName)
%VS_FIND Locates an element in the filestructure of a NEFIS file.
%   Output=vs_find(NFStruct,'ElementName') lists the names of the groups
%   that contain the specified element using the data stored in the
%   NEFIS structure. If the name specified is a group that will be
%   mentioned also.
%
%   If the file (NFStruct) is not specified, the NEFIS that was last opened
%   by VS_USE will be used to read the data. A file structure NFStruct can
%   be obtained as output argument from the function VS_USE.
%
%   See also VS_USE, VS_DISP, VS_LET, VS_GET, VS_DIFF, VS_TYPE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
