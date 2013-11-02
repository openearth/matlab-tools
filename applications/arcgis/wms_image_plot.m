function varargout = wms_image_plot(url,OPT)
%WMS_IMAGE_PLOT download WMS image, save to cache and it render georeferenced
%
% [url,OPT,lims] = wms('server',server,'layers','Ortho');
% wms_image_plot(url,OPT)
%
%See also: wms, imread, urlwrite

  urlwrite(url,[OPT.cachename,OPT.ext]);
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