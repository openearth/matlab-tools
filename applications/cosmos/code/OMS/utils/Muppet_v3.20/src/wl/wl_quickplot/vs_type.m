function filetype=vs_type(vs)
%VS_TYPE Determines the type of the NEFIS file.
%   Type=VS_TYPE(NFStruct) returns the type of NEFIS file based on the file
%   contents. If the function cannot determine the file type, it will
%   return the string 'unknown'. Knowing the file type is not necessary for
%   reading the contents of the NEFIS file; however, it is necessary for
%   understanding the data in the file. If the NFStruct is not a structure
%   corresponding to a NEFIS file, it will return the string 'non-nefis'.
%
%   If the file (NFStruct) is not specified, the NEFIS that was last opened
%   by VS_USE will be used to read the data. A file structure NFStruct can
%   be obtained as output argument from the function VS_USE.
%
%   See also VS_USE, VS_DISP, VS_LET, VS_GET, VS_DIFF, VS_FIND.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
