function out = ishorizontalalignment(value)
%ISHORIZONTALALIGNMENT check whether value is a valid HorizontalAlignment
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = any(strcmpi(value,set(text,'HorizontalAlignment')));

% EOF