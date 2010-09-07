function varargout = KMLlogo(imname,varargin)
%KMLlogo   make a white logo *.png with transparent background of an image
%
%    <kmlcode> = KMLlogo(imagename,<keyword,value>)
% 
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLlogo()
%
% The following see <keyword,value> pairs have been implemented:
%  'fileName'       name of output file, Can be either a *.kml or *.kmz
%                   or *.kmz (zipped *.kml) file. If not defined a gui pops up.
%                   (When 0 or fid = fopen(...) writing to file is skipped
%                   and optional <kmlcode> is returned without KML_header/KML_footer.)
%
% See also: googlePlot, imread

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% import
 
   OPT.fileName         = ''; % header/footer are skipped when is a fid = 0 or fopen(OPT.fileName,'w')
   OPT.logoName         = '';
   OPT.kmlName          = '';
   OPT.description      = '';
   OPT.invertblackwhite = 0; % invert black/white

   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setproperty(OPT, varargin);

%% get filename, gui for filename, if not set yet

   if ischar(OPT.fileName) & isempty(OPT.fileName); % can be char ('', default) or fid
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
      
%% set kmlName if it is not set yet

      if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
      end
   end

%% do image stuff: white image with transparancy ~ lack of white

  [im,map] = imread([imname]);
  
   if ~isempty(map)
   im = ind2rgb(im,map).*255;
   end
   
   % make alpha sum of rgb values
   if OPT.invertblackwhite
   im4alpha =  sum(im,3)./255./3;
   else
   im4alpha = 1-sum(im,3)./255./3;
   end
   im4alpha = im4alpha./max(im4alpha(:));% scale so lightest pixel is fully white
   
   if isempty(OPT.logoName)
   OPT.logoName = fullfile(fileparts(imname),[filename(imname),'4GE.png']);
   end

   imwrite(ones(size(im)),OPT.logoName,'Alpha',im4alpha);
   
%% make kml encapsulation

% <name>logo</name>
%   <ScreenOverlay>
% 	<Icon><href>hydro4GE.png</href></Icon>
% 		<overlayXY  x="0"      y="0.00"  xunits="fraction" yunits="fraction"/>
% 		<screenXY   x="0.02"   y="0.05"  xunits="fraction" yunits="fraction"/>
% 		<size       x="-1"     y="-1"    xunits="fraction"   yunits="fraction"/>
%   </ScreenOverlay>
% </Folder>

   if ischar(OPT.fileName)
      OPT.fid = fopen(OPT.fileName,'w');
      OPT_header = struct(...
                 'name',OPT.kmlName,...
                 'open',0,...
          'description',OPT.description);
      output = KML_header(OPT_header);
      fprintf(OPT.fid,output);
   else
      OPT.fid = OPT.fileName;
   end

   output = '';
   
   output = [output ...
       '<name>logo</name>' ...
       '<Folder><ScreenOverlay>' ...
       '	<Icon><href>' filenameext(OPT.logoName) '</href></Icon>\n' ... % only relative path
       '	<overlayXY  x="0"      y="0.00"  xunits="fraction" yunits="fraction"/>\n' ...
       '	<screenXY   x="0.02"   y="0.05"  xunits="fraction" yunits="fraction"/>\n' ...
       '	<size       x="-1"     y="-1"    xunits="fraction" yunits="fraction"/>\n' ...
       '</ScreenOverlay></Folder>' ];

   if OPT.fid > 0
   fprintf(OPT.fid,output,'%s');
   end
   if nargout==1;kmlcode = output;end % collect all kml for function output

   if ischar(OPT.fileName)
      output = KML_footer;
      fprintf(OPT.fid,output);
      fclose (OPT.fid);
   end
   
if nargout ==1
  varargout = {kmlcode};
end


%% EOF