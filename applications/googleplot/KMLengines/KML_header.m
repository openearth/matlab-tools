function [output] = KML_header(varargin)
%KML_HEADER  low-level routine for creating KML string of header
%
%   kml = KML_header(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * name        name that appears in Google Earth Places list (default 'ans.kml')
%   * description that appears in Google Earth Places list
%   * open        whether to open kml file in GoogleEarth in call of KMLline(default 0)
%
% See also: KML_footer, KML_line, KML_poly, KML_style, KML_stylePoly,
% KML_text, KML_upload

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Properties

OPT.open        = [];
OPT.name        = 'ans.kml';
OPT.description = '';

OPT = setProperty(OPT,varargin{:});

%% type HEADER
output = sprintf([...
    '<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<kml xmlns="http://earth.google.com/kml/2.2">\n'...
    '<!-- Created with Matlab (R) googlePlot toolbox from OpenEarthTools http://www.OpenEarth.eu-->\n',...
    '<Document>\n'...
    '<name>%s</name>\n'...
    '<description>%s</description>\n'...
    '<visibility>1</visibility>\n'...
    '<open>%d</open>\n'],...
    OPT.name,OPT.description, OPT.open);
