function Output=vs_disp(varargin)
%VS_DISP Displays the filestructure of a NEFIS file.
%
%   GENERAL OVERVIEW OF FILE CONTENTS
%   =================================
%   VS_DISP(NFStruct) lists all group names, group elements, and all group
%   and element properties like the "disp stat" command of the stand alone
%   Viewer Selector program for accessing NEFIS file contents.
%
%   VS_DISP(NFStruct,[]) lists only group names, group dimensions, and
%   number of elements per group.
%
%   Output=VS_DISP(NFStruct) or Output=VS_DISP(NFStruct,[]) returns a char
%   array containing the names of the groups.
%
%   CONTENT OF SINGLE GROUP
%   =======================
%   VS_DISP(NFStruct,'GroupName') lists all group elements, and all element
%   properties like the "disp <GroupName>" command of the stand alone
%   Viewer Selector program for accessing NEFIS file contents.
%
%   Output=VS_DISP(NFStruct,'GroupName') returns a char array containing
%   the names of the elements of the group.
%
%   VS_DISP(NFStruct,'GroupName',[]) gives detailed data about the
%   specified group.
%
%   Output=VS_DISP(NFStruct,'GroupName',[]) returns detailed data about the
%   specified group.
%
%   INFORMATION OF A SINGLE ELEMENT
%   ===============================
%   VS_DISP(NFStruct,'GroupName','ElementName') gives detailed data about
%   the specified element.
%
%   Output=VS_DISP(NFStruct,'GroupName','ElementName') returns detailed
%   data about the specified element.
%
%   FOR ALL CASES
%   =============
%   If the file (NFStruct) is not specified, the NEFIS that was last opened
%   by VS_USE will be used to read the data. A file structure NFStruct can
%   be obtained as output argument from the function VS_USE.
%   VS_DISP(FID,...) writes the information to the specified file instead
%   of the command window.
%
%   Example
%      F = vs_use('trim-xxx.dat','trim-xxx.def');
%      vs_disp(F,[]) % show brief listing of all groups
%      vs_disp(F,'map-series') % shows detailed listing of map-series group
%      Info=vs_disp(F,'map-series','S1') % shows detailed info of element
%                                        % S1 in map-series group.
%
%   See also VS_USE, VS_DISP, VS_LET, VS_GET, VS_DIFF, VS_FIND, VS_TYPE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
