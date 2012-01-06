function OPT = KMLcurtain(lat, lon, z, C, varargin)
%KMLCURTAIN  Create a time animated curtain for e.g. adcp data
%
%   Function still in beta!
%
%   Syntax:
%   OPT = KMLcurtain(lat, lon, z, C, <keyword,value>)
%
%   Input:
%   lat      = 1d vector 
%   lon      = 1d vector
%   z        = 1d vector
%   C        = 2d array size(length(z)-1,length(lat)-1)
%
%   C should be 1 shorter than z and lat/lon, because C is center data,
%   lat/lon and z are corner data. Specify the keywords timeIn and 
%   timeOut with the same size as C.
%
%   See also: googlePlot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Jun 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
   % deal with colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   
   % rest of the options
   OPT.fileName           = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.colorMap           = @(m) jet(m);
   OPT.colorSteps         = 16;
   OPT.fillAlpha          = 1;

   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = false;
   OPT.extrude            = false;

   OPT.cLim               = [];
   OPT.zScaleFun          = @(z) (z+30).*1;
   OPT.colorbar           = 0;

   OPT.precision          = 8;
   OPT.tessellate         = false;

if nargin==0
  return
end

%% set properties
[OPT, Set, Default] = setproperty(OPT, varargin{:});


%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% pre-process color data
   c = C;
   
   if isempty(OPT.cLim)
      OPT.cLim         = [min(c(:)) max(c(:))];
   end

   colorRGB = OPT.colorMap(OPT.colorSteps);

   % clip c to min and max 

   c(c<OPT.cLim(1)) = OPT.cLim(1);
   c(c>OPT.cLim(2)) = OPT.cLim(2);

   %  convert color values into colorRGB index values

   c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');
   
   output = KML_header(OPT);
   
   if OPT.colorbar
      clrbarstring = KMLcolorbar(OPT);
      output = [output clrbarstring];
   end

%% STYLE

   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end
   
   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,output);output = '';
   
%% POLYGON

   OPT_poly = struct(...
            'name','',...
       'styleName',['style' num2str(1)],...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
      'visibility',1,...
         'extrude',OPT.extrude,...
      'tessellate',OPT.tessellate,...
       'precision',OPT.precision,...
     'description','');
   
   % preallocate output
   
   output = repmat(char(1),1,1e5);
   kk = 1;
   
   disp(['creating curtain with ' num2str(numel(c)) ' elements...'])
   
   if OPT.reversePoly
      % to be implemented
   end
   
   for jj = 1:size(c,2) 
       OPT_poly.timeIn  = datestr(OPT.timeIn (jj) ,OPT.dateStrStyle);
       OPT_poly.timeOut = datestr(OPT.timeOut(jj) ,OPT.dateStrStyle);
       lat2 = lat(jj + [0 0 1 1 0])';
       lon2 = lon(jj + [0 0 1 1 0])';
       nn   = 1;
        for ii = 1:size(c,1)
            if ii < size(c,1)
                if c(ii,jj) == c(ii+1,jj)
                    nn = nn+1;
                    continue
                end
            end
           OPT_poly.styleName   = sprintf('style%d',c(ii,jj));
           OPT_poly.description = [...
               sprintf('Altitude, Value\n'),...
               sprintf('%8.2f,%8.2f\n',[z(ii+1-nn : ii)' C(ii+1-nn : ii,jj)]')];

           newOutput = KML_poly(...
               lat2,...
               lon2,...
               OPT.zScaleFun(...
               z  (ii+1-nn +[0 1 1 0 0]*nn)'),OPT_poly);  % make sure that LAT(:),LON(:), Z(:) have correct dimension [nx1]
           nn = 1;
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);
           if kk>1e5
               %then print and reset
               fprintf(OPT.fid,output(1:kk-1));
               kk = 1;
               output = repmat(char(1),1,1e5);
           end
       end
   end
   fprintf(OPT.fid,output(1:kk-1)); % print output
   output = '';

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end