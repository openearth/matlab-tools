function out = isposition(value)
%ISPOSITION check whether value is a valid position (for figures etc)
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$
out =  isequal(size(value),[1,4]) && isnumeric(value);

% EOF