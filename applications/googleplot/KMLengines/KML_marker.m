function varargout = KML_marker(lat,lon,varargin)
%KML_MARKER     low-level routine for creating KML string of marker
%
%   kmlstring = KML_marker(lat,lon,<keyword,value>)
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_style, 
% KML_stylePoly, KML_upload

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

%% keyword,value

   OPT.description  = [];
   OPT.icon         = [];
   OPT.name         = [];
   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 29;

   if nargin==0; varargout = {OPT}; return; end
   
   OPT = setproperty(OPT,varargin{:});

%% preproces timespan

   timeSpan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'dateStrStyle',OPT.dateStrStyle);

   if ~isempty(OPT.icon)
       OPT.icon = sprintf('<Style><IconStyle><Icon>%s</Icon></IconStyle></Style>',OPT.icon);
   end
%% 
output = sprintf([...
 '<Placemark>'...
 '%s'...                                                   % timeSpan
 '<name>%s</name>'...                                      % name
 '<description>%s</description>'...                        % description
 '%s'...% icon
 '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>'...
 '</Placemark>\n'],...
 timeSpan,OPT.name,['<![CDATA[',OPT.description,']]>'],OPT.icon,lon,lat);
 
 varargout = {output};

%% EOF