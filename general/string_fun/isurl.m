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

OK = strcmpi(str(1:7),'http://') | ...
     strcmpi(str(1:8),'https://') | ...
     strcmpi(str(1:6),'ftp://');

%% EOF
