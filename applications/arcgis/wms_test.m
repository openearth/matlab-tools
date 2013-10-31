SET.plot = 1; % 0 for catalogue only, 1 to download wms (SLOW)

%% USA Minnesota state aerial imagery
%  test: basic

server = 'http://geoint.lmic.state.mn.us/cgi-bin/wmsll?';
[url,OPT,lims] = wms('server',server,...
    'layers','fsa2010',...
    'swap'  ,1,'flip',0);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  
%% Netherlands aerial imagery
%  test: BoundingBox is a layer property per coordinate system (incl. one 4326 system), and not global 4326 property 
%  test: version=1.1.1 only

% OK:
% http://gdsc.nlr.nl/wms/lufo2005?&service=wms&version=1.1.1&request=GetMap&bbox=2.8146,50.2269,8.1661,54.067&layers=lufo2005-1m&format=image/png&SRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=default

server = 'http://gdsc.nlr.nl/wms/lufo2005?';
[url,OPT,lims] = wms('server',server,...
    'layers','Ortho',...
    'swap'  ,0,'flip',0);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end

%% Belgium aerial imagery
%  test: crashed on http://wms.agiv.be/ogc/wms/omkl?service=WMS&version=1.3.0&request=GetCapabilities&service=WMS

server = 'http://wms.agiv.be/ogc/wms/omkl?';
[url,OPT,lims] = wms('server',server,...
    'layers','Ortho',...
    'swap'  ,1,'flip',0);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  
%% GEBCO
%  test: no style

server = 'http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?';
[url,OPT,lims] = wms('server',server,...
    'layers','',...
    'swap'  ,1,'flip',0);
  url
  if SET.plot  
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  
%% THREDDS MyOcean
%  test: need to use color range and 
%  test: 2 dimenions: elevation + time

server = 'http://data.ncof.co.uk/thredds/wms/METOFFICE-NWS-AF-BIO-DAILY?';
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'swap'  ,0,'flip',1);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  
%% THREDDS bathymetry
%  test: something goes wrong with |lat| > 45
%  test: one dimension: time

server = 'http://geoport.whoi.edu/thredds/wms/bathy/etopo2_v2c.nc?';
[url,OPT,lims] = wms('server',server,...
    'bbox',[],...
    'format','image/png',...
    'layers',1,... % 1st layer
    'styles',9,... % 9th style
    'colorscalerange',[-4000,4000],... % explicit values required for nice colors
    'swap'  ,0,'flip',1);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)  
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  
%% KNMI adaguc buienradar
%  test: requires &service= 
%  test: &srs= in url instead of &crs= 
%  test: one dimension: time as extent
  
server = 'http://geoservices.knmi.nl/cgi-bin/RADNL_OPER_R___25PCPRR_L3.cgi?';
[url,OPT,lims] = wms('server',server,...
    'bbox',[],...
    'crs','EPSG%3A4326',...
    'format','image/png',...
    'layers',2,... % 1st layer
    'styles',9,... % 9th style
    'colorscalerange',[-50,50],... % explicit values required for nice colors
    'swap'  ,0,'flip',1);
  url
  if SET.plot
  urlwrite(url,[OPT.cachename,OPT.ext]);
  [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)  
  print2screensizeoverwrite([OPT.cachename,'_rendered'])
  end
  