function out = isfontweight(fontweight)
%ISFONTWEIGHT check whether fontweight is a valid value
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = any(fontweight(value,set(text,'FontWeight')));

% EOF