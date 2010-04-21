function KMLlogo(imname)
%KMLlogo   make a white logo with transparent background of an image
%
%    KMLlogo(imagename,<keyword,value>)
% 
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLlogo()
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

if 0
   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setProperty(OPT, varargin);
end

%% do image stuff: whote image with transparancy ~ lack of white

   OPT.bgcolor = 255.*[1 1 1];  % background color to be made transparent

   OPT.logorgb = [1 1 1];
   OPT.backrgb = [1 0 0];

  [im,map] = imread([imname]);
  
   if ~isempty(map)
   im = ind2rgb(im,map).*255;
   end
   
   mask   = bsxfun(@eq,im,reshape(OPT.bgcolor,1,1,3));
   
   % make alpha sum of rgb values
   im4alpha = 1-sum(im,3)./255./3; %ind2gray(im,map); % ones(size(mask(:,:,1))).*(1-double(all(mask,3)))
   im4alpha = im4alpha./max(im4alpha(:));% scale so lightest pixel is fully white

   imwrite(ones(size(im)),[filename(imname),'4GE.png'],'Alpha',im4alpha);
   
%% make kml encapsulation

% TO DO

% <?xml version="1.0" encoding="UTF-8"?>
% <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
% <Document>
% <name>OPT.kmlName</name>
% <description>OPT.description</description>
% <Folder>
% 	<ScreenOverlay>
% 		<Icon><href>OPT.FileName</href></Icon>
% 		<overlayXY  x="-0.20"  y="0.05"  xunits="fraction" yunits="fraction"/>
% 		<screenXY   x="-0.20"  y="0.05"  xunits="pixels"   yunits="fraction" xunit="fraction"/>
% 		<rotationXY x="0"  y="0"  xunits="pixels"   yunits="fraction" xunit="fraction"/>
% 		<size       x="-1" y="-1" xunits="pixels"   yunits="pixels"/>
% 	</ScreenOverlay>
% </Folder>
% </Document>
% </kml>
