function OK = isurl(str)
%ISURL   boolean whether char is url or not
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

%%
% check whether string starts with http:// https:// or ftp://
% check is case insensitive
OK = regexpi(str, '^(h|f)tt?ps?://') == 1;
% return boolean

%% EOF
