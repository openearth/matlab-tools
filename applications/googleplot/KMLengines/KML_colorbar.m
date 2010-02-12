function KML_colorbar(OPT)
%KML_COLORBAR   make KML colorbar png
%
%   kmlstring = kml_colorbar(<keyword,value>)
%
%See also: GOOGLEPLOT, KMLcolorbar

   h.fig = figure('Visible','off');
   colormap(OPT.colorMap);
   set(h.fig,'color',OPT.bgcolor./255,'InvertHardcopy','off')
   %% +###+
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
   %% +---+
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
   %% +---+
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
   %% +---+
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
   h.c  = colorbarlegend(gca,[0 1],[0 1],OPT.clim,'ontop',1,'reference','gca','orientation',OPT.orientation);
   set   (h.c,'xcolor'       ,OPT.fontrgb)
   set   (h.c,'ycolor'       ,OPT.fontrgb)
   set   (h.c,'XAxisLocation',OPT.XAxisLocation);
   set   (h.c,'YAxisLocation',OPT.YAxisLocation);
   % set the tick marks if they have been provided
   if isfield(OPT.colorTick)
	  if ~isempty(OPT.colorTick)
	       set(h.c,'YTick',OPT.colorTick);
	  end
   end
   % set the ticklabels if they have been provided
   if isfield(OPT.colorTickLabel)
       if ~isempty(OPT.colorTickLabel)
           set(h.c,'YTickLabel',OPT.colorTickLabel);
       end
   end
   set   (get(h.c,'Title'),'String',OPT.colorTitle,'Color',OPT.fontrgb,'HorizontalAlignment',OPT.horizonalalignment)
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
