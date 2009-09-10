function varargout = KMLscatter(lat,lon,c,varargin)
%KMLscatter  Just like scatter and plotc
%
%   kmlscatter(lat,lon,c,<keyword,value>)
%
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename           = []; % file name 
%  * kmlname            = []; % name that appears in Google Earth places list
%  * colorMap           = colormap (default @(m) jet(m));
%  * colorSteps         = number of colors in colormap (default 20);
%  * clim               = clim aka caxis (default [min(c) max(c)]); 
%  * long_name          = ''; used for point description ... (default 'value=')
%  * units              = ''; 'long_name = x units'  (NB '%' sign not allowed, default '')
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = kmlscatter()
%
%See also: GOOGLEPLOT, SCATTER, PLOTC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% process options

   OPT.filename           =  [];
   OPT.kmlname            =  [];
   OPT.colorMap           =  @(m) jet(m);
   OPT.colorSteps         =  20;
   OPT.clim               =  [];
   OPT.long_name          =  'value=';
   OPT.units              =  ''; % '% not allowed
   OPT.iconnormalState    =  'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
   OPT.iconhighlightState =  'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
   OPT.scalenormalState   =  0.25;
   OPT.scalehighlightState=  1.0;
   OPT.openInGE           =  0;
   OPT.markerAlpha        =  0.6;
   OPT.description        =  '';
   
   if nargin==0
     varargout = {OPT};
     return
   end
   
   [OPT, Set, Default] = setProperty(OPT, varargin);
   
   if any(strfind(OPT.units,'%'));error('no % allowed in units');end

%% get filename

   if isempty(OPT.filename)
     [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
     OPT.filename = fullfile(filePath,fileName);
   end
% set kmlName if it is not set yet

   if isempty(OPT.kmlname)
      [ignore OPT.kmlname] = fileparts(OPT.filename);
   end

%% set clim

   if isempty(OPT.clim)
      OPT.clim         = [min(c(:)) max(c(:))];
   end

%% pre-process data
%  make 1D and remove NaNs

   lon    = lon(~isnan(c(:)));
   lat    = lat(~isnan(c(:)));
   c      =   c(~isnan(c(:)));
   colors = OPT.colorMap(OPT.colorSteps);

%% start KML

   OPT.fid=fopen(OPT.filename,'w');

%% HEADER

   OPT_header = struct(...
           'name',OPT.kmlname,...
           'open',0,...
    'description',OPT.description);
   output = KML_header(OPT_header);

   output = [output '<!--############################-->\n'];

%% STYLE

   for ii = 1:OPT.colorSteps

   OPT_stylePoly.name      = ['style' num2str(ii)];
   temp        = dec2hex(round([OPT.markerAlpha, colors(ii,:)].*255),2);
   markerColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

   output = [output ...
       '<StyleMap id="Speed_marker_',num2str(ii,'%0.3d'),'map">\n'...
       ' <Pair><key>normal</key><styleUrl>#Speed_marker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>\n'...
       ' <Pair><key>highlight</key><styleUrl>#Speed_marker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>\n'...
       '</StyleMap>\n'...
       '<Style id="Speed_marker_',num2str(ii,'%0.3d'),'n">\n'...
       ' <IconStyle>\n'...
       ' <color>' markerColor '</color>\n'...
       ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'...
       ' <Icon><href>' OPT.iconnormalState '</href></Icon>\n'...
       ' </IconStyle>\n'...
       ' <LabelStyle><color>ff0055ff</color></LabelStyle>\n'...
       ' </Style>\n'...
       '<Style id="Speed_marker_',num2str(ii,'%0.3d'),'h">\n'...
       ' <BalloonStyle><text>\n'...
       ' $[description]\n'...
       ' </text></BalloonStyle>\n'...
       ' <IconStyle>\n'...
       ' <color>' markerColor '</color>\n'...
       ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...
       ' <Icon><href>' OPT.iconhighlightState '</href></Icon>\n'...
       ' </IconStyle>\n'...
       ' <LabelStyle><color>ff0055ff</color></LabelStyle>\n'...
       ' </Style>\n'];
   end

   output = [output '<!--############################-->\n'];

%% print and clear output

   fprintf(OPT.fid,output); output = [];

%% Plot the points

   for i=1:length(lon)

      % convert color values into colorRGB index values
      cindex = round(((c(i)-OPT.clim(1))/(OPT.clim(2)-OPT.clim(1))*(OPT.colorSteps-1))+1);
      cindex = min(cindex,OPT.colorSteps);
      cindex = max(cindex,1); % style numbering is 1-based
      
      OPT_poly.styleName = ['Speed_marker_',num2str(cindex,'%0.3d'),'map'];
      
      output = [output ...
          '<Placemark>\n'...
          ' <visibility>1</visibility>\n'...
          ' <description>' OPT.long_name ' = ' num2str(c(i)) ' ' OPT.units '</description>\n'...
          ' <styleUrl>#'   OPT_poly.styleName '</styleUrl>\n'...
          ' <Point><coordinates>' num2str(lon(i)) ',' num2str(lat(i)) ',0</coordinates></Point>\n'...
          ' </Placemark>\n'];
      
   end

%output = [output '</Folder>\n'];

%% print and clear output

   fprintf(OPT.fid,output); 

%% FOOTER

   output = KML_footer;
   fprintf(OPT.fid,output);

%% close KML

   fclose(OPT.fid);

%% openInGoogle?

   if OPT.openInGE
      system(OPT.filename);
   end

%% Output

   if nargout==1
      varargout = {handles};
   end

%% EOF

