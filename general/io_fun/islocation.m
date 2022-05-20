function out = islocation(value)
%ISLOCATION check whether value is a valid Location
%See also: 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

out = any(strcmpi(value,{
    'Center'
    'North'
    'South'
    'East'
    'West'
    'NorthEast'
    'SouthEast'
    'NorthWest'
    'SouthWest'    
}));

% EOF
