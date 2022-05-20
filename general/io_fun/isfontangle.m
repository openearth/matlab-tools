function out = isfontangle(fontangle)
%ISFONTANGLE check whether fontangle is a valid value
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = any(fontangle(value,set(text,'FontAngle')));

% EOF