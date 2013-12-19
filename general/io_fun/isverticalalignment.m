function out = isverticalalignment(value)
%ISVERTICALALIGNMENT check whether value is a valid VerticalAlignment
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = any(strcmpi(value,set(text,'VerticalAlignment')));

% EOF