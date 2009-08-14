function [output] = KML_text(lat,lon,text,varargin)
%KML_TEXT   low-level routine for creating KML string of text
%
%   kmlstring = KML_text(lat,lon,text)
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

%%
OPT.timeIn     = [];
OPT.timeOut    = [];

OPT = setProperty(OPT,varargin{:});

%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...OPT.timeIn
            '<end>%s</end>\n'...OPT.timeOut
            '</TimeSpan>\n'],...
            OPT.timeIn,OPT.timeOut);
    else
        timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...OPT.timeIn
            '</TimeStamp>\n'],...
            OPT.timeIn);
    end
else
    timeSpan ='';
end


%% type HEADER
output = sprintf([...
	'<Placemark>'...
    '%s',...% timeSpan
	'<name>%s</name>'...
	'<Style><IconStyle><Icon></Icon></IconStyle></Style>'...
	'<Point>	<coordinates>%3.8f,%3.8f,0</coordinates></Point>'...
	'</Placemark>'],...
    timeSpan,text,lon,lat);

%% EOF