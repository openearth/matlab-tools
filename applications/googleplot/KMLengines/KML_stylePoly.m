function [output] = KML_stylePoly(varargin)
%KML_STYLEPOLY low-level routine for creating KML string of polygon style
%
%   kmlstring = KML_style(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * name        name of style (default '')
%   * lineColor   color of the lines in RGB (0..1) values, default white ([0 0 0])
%   * lineAlpha   transparency of the line, (0..1) with 0 transparent
%   * lineWidth   line width, can be a fraction (default 1)
%   * fillColor   area color in RGB (0..1) values, default black ([1 0 0])
%   * fillAlpha   area transparency, (0..1) with 0 transparent (default 1)
%   * polyFill    whether to fill or not (default 1)
%   * polyOutline whether to outline (default 1)
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_style, 
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

OPT.name        = 'black';
OPT.lineColor   = [0 0 0];
OPT.lineAlpha   = 1;
OPT.lineWidth   = 1;
OPT.fillColor   = [1 0 0];
OPT.fillAlpha   = 1;
OPT.polyFill    = 1;
OPT.polyOutline = 1;

if nargin==0
   output = OPT;
   return
end

OPT = setproperty(OPT,varargin{:});

%% type STYLE
temp      = dec2hex(round([OPT.lineAlpha, OPT.lineColor].*255),2);
lineColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];
temp      = dec2hex(round([OPT.fillAlpha, OPT.fillColor].*255),2);
fillColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

output = sprintf([...
    '<Style id="%s">\n'...       % OPT.name
    '<LineStyle>\n'...
    '<color>%s</color>\n'...     % lineColor
    '<width>%d</width>\n'...     % OPT.lineWidth
    '</LineStyle>\n'...
    '<open>1</open>\n',...
    '<PolyStyle>\n'...
    '<color>%s</color>\n'...     % fillColor
    '<outline>%d</outline>\n'... % OPT.polyOutline
    '<fill>%d</fill>\n'...       % OPT.polyFill
    '</PolyStyle>\n'...
    '</Style>\n'],...
    OPT.name,lineColor,OPT.lineWidth,...
    fillColor,OPT.polyOutline,OPT.polyFill);
