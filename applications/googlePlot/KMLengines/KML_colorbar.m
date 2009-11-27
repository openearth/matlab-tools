function KML_colorbar(OPT)
%KML_COLORBAR   make KML colorbar png
%
%   kmlstring = kml_colorbar(<keyword,value>)
%
%See also: GOOGLEPLOT, KMLcolorbar

   h.fig = figure;
   colormap(OPT.colorMap)
   set(h.fig,'color',OPT.bgcolor./255,'InvertHardcopy','off')
   if              strcmpi(OPT.orientation,'horizontal') & ...
                   strcmpi(OPT.verticalalignment,'top')
      axes('position',[    OPT.tipmargin 
                       1-  OPT.thickness-OPT.alignmargin
                       1-2*OPT.tipmargin
                           OPT.thickness]);
                           OPT.XAxisLocation = 'bottom';
   elseif          strcmpi(OPT.orientation,'horizontal') & ...
                   strcmpi(OPT.verticalalignment,'bottom')
      axes('position',[    OPT.tipmargin 
                           OPT.alignmargin
                       1-2*OPT.tipmargin
                           OPT.thickness]);
                           OPT.XAxisLocation = 'top';
   elseif          strcmpi(OPT.orientation       ,'vertical') & ...
                   strcmpi(OPT.horizonalalignment,'right')
      axes('position',[1-  OPT.thickness-OPT.alignmargin ...
                           OPT.tipmargin ...
                           OPT.thickness...
                       1-2*OPT.tipmargin]);
                           OPT.XAxisLocation = 'bottom'; % dummy
   else
      error('KMLcolorbar')
   end
   h.ax = gca;
   h.c  = colorbarlegend(gca,[0 1],[0 1],OPT.clim,'ontop',1,'reference','gca','orientation',OPT.orientation);
   set   (h.c,'xcolor'       ,OPT.fontcolor)
   set   (h.c,'ycolor'       ,OPT.fontcolor)
   set   (h.c,'XAxisLocation',OPT.XAxisLocation);
   delete(h.ax)
   box on
   print ([OPT.fileName,'.png'],'-dpng')
   im   = imread([OPT.fileName,'.png']);
   mask = bsxfun(@eq,im,reshape(OPT.bgcolor,1,1,3));
   imwrite(im,[OPT.fileName,'.png'],'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3))));
   close(h.fig);
