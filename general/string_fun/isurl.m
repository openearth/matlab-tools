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

OK = strcmpi(str(1:7),'http://');

%% EOF
