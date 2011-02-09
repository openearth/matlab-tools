function varargout = KML_header(varargin)
%KML_HEADER  low-level routine for creating KML string of header
%
%   kml = KML_header(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * name         name that appears in Google Earth Places list (default 'ans.kml')
%   * description  that appears in Google Earth Places list
%   * open         whether to open kml file in GoogleEarth in call of KMLline(default 0)
%   * visible      whther by default visible outside GE list item menu
% 
%   * cameralon    specify camera viewpoint
%   * cameralat    specify camera viewpoint
%   * cameraz      specify camera viewpoint
%
%   * timeIn       specify timespan of timeslider (datenum or yyyy-mm-ddTHH:MM:SS)
%   * timeOut      specify timespan of timeslider (datenum or yyyy-mm-ddTHH:MM:SS)
%   * dateStrStyle how to write time string into kml: dtermines accuracy (default 29)
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

   OPT.open         = [];
   OPT.kmlName      = '';
   OPT.description  = '';
   OPT.visible      = 1;

   OPT.cameralon    = [];
   OPT.cameralat    = [];
   OPT.cameraz      = [];
   
   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 'yyyy-mm-ddTHH:MM:SSZ';
   
   if nargin==0; varargout = {OPT}; return; end

   if isstruct(varargin{1})
      OPT = mergestructs(OPT,varargin{1}); % varargin struct can have field that are not in OPT
   else
      OPT = setproperty(OPT,varargin{:}); % varargin struct can NOT have any field that is not in OPT
   end

%% preproces timespan

   timeSpan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'dateStrStyle',OPT.dateStrStyle);
   
%% camera

   if ~(isempty(OPT.cameralon) || isempty(OPT.cameralat) || isempty(OPT.cameraz))
      camera = sprintf([...
      '<Camera>\n'...
      '	<longitude>%g</longitude>\n'...
      '	<latitude>%g</latitude>\n'...
      '	<altitude>%g</altitude>\n'...
      '%s'...
      '</Camera>\n'],OPT.cameralon,OPT.cameralat,OPT.cameraz,timeSpan); % timespan only works when also coordinates are supplied
   else
      camera = '';
   end

%% type HEADER

   output = sprintf([...
    '<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n'...
    '<!-- Created with Matlab (R) googlePlot toolbox $Version$ $Date$ from OpenEarthTools http://www.OpenEarth.eu-->\n',...
    '<Document>\n'...
    '%s'...
    '<name>%s</name>\n'...
    '<description>%s</description>\n'...
    '<visibility>%s</visibility>\n'...
    '<open>%d</open>\n' ],...
    camera,OPT.kmlName , OPT.description, num2str(OPT.visible), OPT.open);

   varargout = {output};