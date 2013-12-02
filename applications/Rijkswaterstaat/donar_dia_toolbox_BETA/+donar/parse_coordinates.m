function out = parse_coordinates(in,varargin)
%parse_coordinates  convert donar value to coordinate [degrees]
%
%   out = donar.parse_coordinates(in)
%
% where in can be one value, or an array, such as the 
% 1st of 2nd column of  block_data = donar.read_block();
%
% TO DO handle other coordinate systems than (lon,lat) WGS84.
%
%See also: parse_time

% use varargin for handling coordinate type

out = dms2degrees([mod(fix(in/1000000),100), ...
                   mod(fix(in/10000  ),100), ...
                   mod(    in,10000  )/100]);