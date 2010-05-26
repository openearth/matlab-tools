function [output] = KML_marker(lat,lon,varargin)
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

   OPT.description = [];
   OPT.icon        = 'http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png';
   OPT.name        = [];
   OPT.timeIn      = [];
   OPT.timeOut     = [];
   
   OPT = setproperty(OPT,varargin{:});
   
   if nargin==0
      output = OPT;
      return
   end

%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'... % OPT.timeIn
            '<end>%s</end>\n'...     % OPT.timeOut
            '</TimeSpan>\n'],...
            OPT.timeIn,OPT.timeOut);
    else
        timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...   % OPT.timeIn
            '</TimeStamp>\n'],...
            OPT.timeIn);
    end
else
    timeSpan =' ';
end

%% 
output = sprintf([...
 '<Placemark>'...
 '%s'...                                                   % timeSpan
 '<name>%s</name>'...                                      % name
 '<description>%s</description>'...                        % description
 '<Style><IconStyle><Icon>%s</Icon></IconStyle></Style>'...% icon
 '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>'...
 '</Placemark>'],...
 timeSpan,OPT.name,['<![CDATA[',OPT.description,']]>'],OPT.icon,lon,lat);

%% EOF