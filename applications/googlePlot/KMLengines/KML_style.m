function [output] = KML_style(OPT)
% KML_STYLE define line style
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_stylePoly,
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

%% 
temp = dec2hex(round([OPT.lineAlpha, OPT.lineColor].*255));
lineColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

output = sprintf([...
    '<Style id="%s">\n'...
    '<LineStyle>\n'...
    '<color>%s</color>\n'...
    '<width>%d</width>\n'...
    '</LineStyle>\n'...
    '<open>1</open>\n',...
    '</Style>\n'],...
    OPT.name,lineColor,OPT.lineWidth);
