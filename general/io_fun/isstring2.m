function out = isstring(value)
%ISSTRING check whether value is a valid string (for string property in)
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$
out =  ischar(value) || iscellstr(value);

% EOF
