function OK = isurl(str)
%ISURL   boolend whether char is url or not
%
% ok = isurl(string)
%
% See also: urlread

% $Id: isurl.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/string_fun/isurl.m $
% $Keywords$

OK = (length(str) >5 && strcmpi(str(1:6),'ftp://'  )) || ...
     (length(str) >6 && strcmpi(str(1:7),'http://' )) || ...
     (length(str) >7 && strcmpi(str(1:8),'https://'));

%% EOF
