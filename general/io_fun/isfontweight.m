function out = isfontweight(value)
%ISFONTWEIGHT check whether fontweight is a valid value
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% out = any(fontweight(value,set(text,'FontWeight')));
out = any(strcmpi(value,set(text,'FontWeight')));

% EOF