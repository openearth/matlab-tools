function KML_colorbar(OPT)
%KML_COLORBAR   make KML colorbar png
%
%   kmlstring = kml_colorbar(<keyword,value>)
%
%See also: GOOGLEPLOT, KMLcolorbar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: K$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   h.fig = figure('Visible','off');
   colormap(OPT.colorMap);
   set(h.fig,'color',OPT.bgcolor./255,'InvertHardcopy','off')
   %% locations
   %
   %  +###+
   %  |   |
   %  +---+
   if              strcmpi(OPT.orientation      ,'horizontal') & ...
                   strcmpi(OPT.verticalalignment,'top')
      axes('position',[    OPT.tipmargin
                       1-  OPT.thickness-OPT.alignmargin
                       1-2*OPT.tipmargin    % width
                           OPT.thickness]); % height
                           OPT.XAxisLocation = 'bottom';
                           OPT.YAxisLocation = 'left'; % dummy
   %  +---+
   %  |   |
   %  +###+
   elseif          strcmpi(OPT.orientation      ,'horizontal') & ...
                   strcmpi(OPT.verticalalignment,'bottom')
      axes('position',[    OPT.tipmargin
                           OPT.alignmargin
                       1-2*OPT.tipmargin    % width
                           OPT.thickness]); % height
                           OPT.XAxisLocation = 'top';
                           OPT.YAxisLocation = 'left'; % dummy
   %  +---+
   %  |   #
   %  +---+
   elseif          strcmpi(OPT.orientation       ,'vertical') & ...
                   strcmpi(OPT.horizonalalignment,'right')
      axes('position',[1-  OPT.thickness-OPT.alignmargin
                           OPT.tipmargin
                           OPT.thickness    % width
                       1-2*OPT.tipmargin]); % height
                           OPT.XAxisLocation = 'bottom'; % dummy
                           OPT.YAxisLocation = 'left';
   %  +---+
   %  #   |
   %  +---+
   elseif          strcmpi(OPT.orientation       ,'vertical') & ...
                   strcmpi(OPT.horizonalalignment,'left')
      axes('position',[    OPT.alignmargin
                           OPT.tipmargin
                           OPT.thickness    % width
                       1-2*OPT.tipmargin]); % height
                           OPT.XAxisLocation = 'bottom'; % dummy
                           OPT.YAxisLocation = 'right';
   else
      error('KMLcolorbar')
   end
   h.ax = gca;
   if OPT.clim(1)==OPT.clim(2)
      OPT.clim = OPT.clim + 10.*[-eps eps];
   end
   h.c  = colorbarlegend(gca,[0 1],[0 1],OPT.clim,...
            'ontop',0,...
        'reference','gca',...
      'orientation',OPT.orientation);%,...
           %'title',OPT.colorTitle,...
   %'titleposition',[OPT.orientation(1),'text'],...
      %'titlecolor',OPT.fontrgb);
        if     strcmpi(OPT.orientation      ,'vertical') 
           text(-0.1,0,[' ',OPT.colorTitle],'color',OPT.titlergb,'units','normalized','rotation',90,'verticalalignment','top');
        elseif strcmpi(OPT.orientation      ,'horizontal')
           text(0,0.05,[' ',OPT.colorTitle],'color',OPT.titlergb,'units','normalized','rotation', 0,'verticalalignment','bottom');
        end
  %h.t = get(h.c,'Title');    
  %set   (h.t,'color'        ,OPT.fontrgb)
   set   (h.c,'xcolor'       ,OPT.fontrgb)
   set   (h.c,'ycolor'       ,OPT.fontrgb)
   set   (h.c,'XAxisLocation',OPT.XAxisLocation);
   set   (h.c,'YAxisLocation',OPT.YAxisLocation);
   % set the tick marks if they have been provided
   if isfield(OPT,'colorTick')
	  if ~isempty(OPT.colorTick)
        if     strcmpi(OPT.orientation      ,'vertical')  
        set(h.c,'YTick',OPT.colorTick);
        elseif strcmpi(OPT.orientation      ,'horizontal')
        set(h.c,'XTick',OPT.colorTick);           
        end
	  end
   end
   % set the ticklabels if they have been provided
   if isfield(OPT,'colorTickLabel')
       if ~isempty(OPT.colorTickLabel)
        if     strcmpi(OPT.orientation      ,'vertical');          
           set(h.c,'YTickLabel',OPT.colorTickLabel);
        elseif strcmpi(OPT.orientation      ,'horizontal')
           set(h.c,'XTickLabel',OPT.colorTickLabel);           
        end
       end
   end
   delete(h.ax)
   box on
   print ([OPT.fileName,'.png'],'-dpng')
   im   = imread([OPT.fileName,'.png']);
   mask = bsxfun(@eq,im,reshape(OPT.bgcolor,1,1,3));

   %% replace all colors under invisble pixels with black (0 0 0) (OPT.fontrgb)
   %  which are the well readable google letters

   for ic=1:3
      onecolor = im(:,:,ic);
      onecolor(all(mask,3)) = OPT.halorgb(ic)*255;
      im(:,:,ic)  = onecolor;
   end

   %% now let alpha gradually decrease from 0 inside to 1 outside

   if OPT.halo
   s1 = all(mask,3);
   s2 = ~ceil((~s1([1 1:end-1],[1 1:end-1]) + ...
               ~s1([2:end end],[1 1:end-1]) + ...
               ~s1([1 1:end-1],[2:end end]) + ...
               ~s1([2:end end],[2:end end]))/4); % move letters 1 pixel around
   s3 = ~ceil((~s2([1 1:end-1],[1 1:end-1]) + ...
               ~s2([2:end end],[1 1:end-1]) + ...
               ~s2([1 1:end-1],[2:end end]) + ...
               ~s2([2:end end],[2:end end]))/4); % move letters 1other pixel around

   blend = zeros(size(s1)); % alpha value to add ONLY to pixels adjacent to letters and colorbar
   blend(logical(s1-s3))= 0.5;
   blend(logical(s1-s2))= 1.0;
   imwrite(im,[OPT.fileName,'.png'],'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3)) + blend));
   else
   imwrite(im,[OPT.fileName,'.png'],'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3))));
   end

   try;close(h.fig);end

%% EOF
