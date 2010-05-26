function varargout = KMLsurf(lat,lon,z,varargin)
% KMLSURF Just like surf
%
%   KMLsurf(lat,lon,z,<keyword,value>)
%   KMLsurf(lat,lon,z,c,<keyword,value>)
%
% where z needs to be specified at the corners (same size as lon,lat
% wheras c can be specified  either at the corners or at the centers.
% If c and lat have the same dimensions (c at corners), c is calculated 
% ath the centers as the mean value of the surrounding gridpoints. 
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLsurf()
%
% The keyword 'colorMap' can either be a function handle to be sampled with
% keyword 'colorSteps', or a colormap rgb array (then 'colorSteps' is ignored).
%
% See also: googlePlot, surf

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

%% process <keyword,value>
   % get colorbar options first
   OPT                    = KMLcolorbar();
   % rest of the options
   OPT.fileName           = '';
   OPT.kmlName            = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.colorMap           = @(m) jet(m); % function(OPT.colorSteps) or an rgb array
   OPT.colorSteps         = 16;
   OPT.fillAlpha          = 0.6;
   OPT.polyOutline        = false;
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = false;
   OPT.extrude            = false;
   OPT.cLim               = [];
   OPT.zScaleFun          = @(z) (z+20).*5;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.colorbar           = 1;
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% assign c if it is given

   if ~isempty(varargin)
       if ~ischar(varargin{1})&&~isstruct(varargin{1});
           c = varargin{1};
           varargin = varargin(2:length(varargin));
       else
           c = z;
       end
   else
       c = z;
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

%% error check

   if all(isnan(z(:)))
      disp('warning: No surface could be constructed, because there was no valid height data provided...') %#ok<WNTAG>
      return
   end

%% calaculate center color values

   if all(size(c)==size(lat))
       c = (c(1:end-1,1:end-1)+...
            c(2:end-0,2:end-0)+...
            c(2:end-0,1:end-1)+...
            c(1:end-1,2:end-0))/4;
   elseif ~all(size(c)+[1 1]==size(lat))
       error('wrong color dimension, must be equal or one less as lat/lon')
   end

%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(c(:)) max(c(:))];
   end

   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
   end
   
   if isa(OPT.colorMap,'function_handle')
     colorRGB           = OPT.colorMap(OPT.colorSteps);
   elseif isnumeric(OPT.colorMap)
     if size(OPT.colorMap,1)==1
       colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
     elseif size(OPT.colorMap,1)==OPT.colorSteps
       colorRGB         = OPT.colorMap;
     else
       error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
     end
   end

   % clip c to min and max 

   c(c<OPT.cLim(1)) = OPT.cLim(1);
   c(c>OPT.cLim(2)) = OPT.cLim(2);

   %  convert color values into colorRGB index values

   c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');
   
   OPT_header = struct(...
       'name',OPT.kmlName,...
       'open',0);
   output = KML_header(OPT_header);

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
       OPT_stylePoly.name      = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       if strcmpi(OPT.lineColor,'fillColor')
           OPT_stylePoly.lineColor = colorRGB(ii,:);
       end
       output = [output KML_stylePoly(OPT_stylePoly)];
   end
   
   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,'%s',output); output = [];
   fprintf(OPT.fid,'<Folder>');
   fprintf(OPT.fid,'  <name>patches</name>');
   fprintf(OPT.fid,'  <open>0</open>');

%% POLYGON

   OPT_poly = struct(...
   'name'      ,'',...
   'styleName' ,['style' num2str(1)],...
   'timeIn'    ,datestr(OPT.timeIn ,29),...
   'timeOut'   ,datestr(OPT.timeOut,29),...
   'visibility',1,...
   'extrude'   ,OPT.extrude);
   
   % preallocate output
   
   output = repmat(char(1),1,1e5);
   kk = 1;
   
   % put nan values in lat and lon on a size -1 array
   
   lat_nan = isnan(lat(1:end-1,1:end-1)+...
                   lat(2:end-0,2:end-0)+...
                   lat(2:end-0,1:end-1)+...
                   lat(1:end-1,2:end-0));
   lon_nan = isnan(lon(1:end-1,1:end-1)+...
                   lon(2:end-0,2:end-0)+...
                   lon(2:end-0,1:end-1)+...
                   lon(1:end-1,2:end-0)); 
   col_nan = isnan(c);
   
   % add everything into a 'not'nan' array, of size: size(lat)-[1 1]
   
   not_nan = ~(lat_nan|lon_nan|col_nan);         
   disp(['creating surf with ' num2str(sum(sum(not_nan))) ' elements...'])
   
   for ii=1:length(lat(:,1))-1
       for jj=1:length(lon(1,:))-1
           if not_nan(ii,jj)
               LAT = [lat(ii+1,jj) lat(ii+1,jj+1) lat(ii,jj+1) lat(ii,jj) lat(ii+1,jj)];
               LON = [lon(ii+1,jj) lon(ii+1,jj+1) lon(ii,jj+1) lon(ii,jj) lon(ii+1,jj)];
               Z =   [  z(ii+1,jj)   z(ii+1,jj+1)   z(ii,jj+1)   z(ii,jj)   z(ii+1,jj)];
               OPT_poly.styleName = sprintf('style%d',c(ii,jj));
               if OPT.reversePoly
                   LAT = LAT(end:-1:1);
                   LON = LON(end:-1:1);
                     Z =   Z(end:-1:1);
               end
               newOutput = KML_poly(LAT(:),LON(:),OPT.zScaleFun(Z(:)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
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
   end
   fprintf(OPT.fid,output(1:kk-1)); output = ''; % print and clear output
   
   fprintf(OPT.fid,'</Folder>');

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

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end

%% EOF
