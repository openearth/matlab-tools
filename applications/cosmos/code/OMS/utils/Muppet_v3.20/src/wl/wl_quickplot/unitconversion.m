function varargout=unitconversion(unit1,unit2,varargin)
%UNITCONVERSION Convert unit strings.
%   SystemList = UNITCONVERSION('systems') returns the unit systems
%   supported. Currently these are SI, CGS, FPS, IPS, NMM.
%
%   UnitList = UNITCONVERSION('units') returns a list of all supported
%   elementary unit strings. Unit strings may be combined of any
%   combination of units. E.g. 'km/h', 'ft/s', 'N*s/kg'.
%
%   UNITCONVERSION(UStr1,UStr2) displays a conversion table for
%   transforming quantities expressed in UStr1 into UStr2 and vice versa.
%
%   ConversionFactor = UNITCONVERSION(UStr,UStr2) returns the factor
%   needed for the conversion of quantities expressed in UStr1 into UStr2.
%
%   UNITCONVERSION(UStr1,System) displays a conversion table for
%   transforming quantities expressed in UStr1 into the equivalent in the
%   selected unit system and vice versa.
%
%   [ConversionFactor,UStr2] = UNITCONVERSION(UStr1,System) returns the
%   factor needed for the conversion of quantities expressed in unit1 into
%   the equivalent in the selected unit system and returns the unit string
%   UStr2 in that system as well.
%
%   DATA2 = UNITCONVERSION(UStr1,UStr2,DATA1) converts the data provided by
%   DATA1 in UStr1 unit into UStr2 units.
%
%   Note: The current support for temperature concerns relative
%   temperatures only, i.e. 5 degrees celsius will be converted to 5
%   degrees kelvin. This is correct for temperature differences but not for
%   absolute temperatures.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
