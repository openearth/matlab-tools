function fname=visdiffGetFullPathname(fname)
%VISDIFFGETFULLPATHNAME Helper function for visdiff that changes a relative
%   pathname into a full pathname.  If the full path cannot be found, the
%   input argument is returned.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

pt = fileparts(fname);
% Respect a fully qualified path if one is being given
if isempty(pt)
    whichpath = which(fname);
    if (~isempty(whichpath))
        fname = whichpath;
    end
end