function varargout = wms_image_plot(url,OPT)
%WMS_IMAGE_PLOT download WMS image, save to cache and it render georeferenced
%
% [url,OPT,lims] = wms('server',server,'layers','Ortho');
% wms_image_plot(url,OPT)
%
%See also: wms, imread, urlwrite

%% download cache of image  
   urlwrite(url,[OPT.cachename,OPT.ext]);
   
   disp(['Cached WMS image to:',OPT.cachename,OPT.ext])
  
%% make kml wrapper for cached image
   KMLimage(OPT.axis([2 4]),OPT.axis([1 3]),url,'fileName',[OPT.cachename,'.kml'])
  
%% TODO make world file  
  
%% plot georeferenced in matlab for testing
   [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
   image(OPT.x,OPT.y,A)
   colormap(map)
   tickmap('ll');grid on;
   set(gca,'ydir','normal')
   %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
   %TODO colorbarwithvtext(OPT.layers)
   print2screensizeoverwrite([OPT.cachename,'_rendered'])
  
   if nargout > 0
      varargout = {A,map,alpha};
   end