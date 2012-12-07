function OK = isurl(str)
%ISURL   boolend whether char is url or not
%
% ok = isurl(string)
%
% See also: urlread

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

OK = (length(str) >5 && strcmpi(str(1:6),'ftp://'  )) || ...
     (length(str) >6 && strcmpi(str(1:7),'http://' )) || ...
     (length(str) >7 && strcmpi(str(1:8),'https://'));

%% EOF
