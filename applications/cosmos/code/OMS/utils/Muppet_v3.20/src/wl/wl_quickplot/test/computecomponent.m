function [data,scalar,vpt]=computecomponent(data,Ops)
%COMPUTECOMPONENT Compute component of vector data set.
%
%   NewData = COMPUTECOMPONENT(Data,Component)
%   where Data is a vector data structure obtained from QPREAD and
%   Component equals one of the following strings: 'magnitude',
%   'magnitude in plane', 'angle (radians)', 'angle (degrees)',
%   'x component', 'y component', 'z component', 'm component',
%   'n component', 'k component'

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
