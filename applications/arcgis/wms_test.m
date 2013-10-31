SET.plot = 1; % 0 for catalogue onyl, 1 to download wms (SLOW)
%% USA Minnesota state aerial imagery: OK
% test: basic
server = 'http://geoint.lmic.state.mn.us/cgi-bin/wmsll?';
[url,OPT,lims] = wms('server',server,...
    'layers','fsa2010',...
    'swap'  ,1,'flip',0);
  url
  if SET.plot
  urlwrite(url,[mkvar(server),OPT.ext]);
  [A,map,alpha] = imread([mkvar(server),OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensize([mkvar(server),'_rendered'])
  end
  
%% GEBCO: special: 
% test: no style
server = 'http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?';
[url,OPT,lims] = wms('server',server,...
    'layers','',...
    'swap'  ,1,'flip',0);
  url
  if SET.plot  
  urlwrite(url,[mkvar(server),OPT.ext]);
  [A,map,alpha] = imread([mkvar(server),OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  print2screensize([mkvar(server),'_rendered'])
  end
  
 %% THREDDS  MyOcean
 % test: need to use color range and 
 % test: 2 dimenions: elevation + time
server = 'http://data.ncof.co.uk/thredds/wms/METOFFICE-NWS-AF-BIO-DAILY?';
[url,OPT,lims] = wms('server',server,...
    'layers','CHL',...
    'colorscalerange',[0,1],...  % explicit values required for nice colors
    'swap'  ,0,'flip',1);
  url
  if SET.plot
  urlwrite(url,[mkvar(server),OPT.ext]);
  [A,map,alpha] = imread([mkvar(server),OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)
  print2screensize([mkvar(server),'_rendered'])
  end
 %% THREDDS  bathy
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
  urlwrite(url,[mkvar(server),OPT.ext]);
  [A,map,alpha] = imread([mkvar(server),OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)  
  print2screensize([mkvar(server),'_rendered'])
  end
  %% KNMI adaguc buienradar
  % test: requires &service= 
  % test: &srs= in url instead of &crs= 
  % test: one dimension: time as extent
  
server = 'http://geoservices.knmi.nl/cgi-bin/RADNL_OPER_R___25PCPRR_L3.cgi?';
[url,OPT,lims] = wms('server',server,...
    'bbox',[],...
    'crs','EPSG%3A4326',...
    'format','image/png',...
    'layers',1,... % 1st layer
    'styles',9,... % 9th style
    'colorscalerange',[-50,50],... % explicit values required for nice colors
    'swap'  ,0,'flip',1);
  url
  if SET.plot
  urlwrite(url,[mkvar(server),OPT.ext]);
  [A,map,alpha] = imread([mkvar(server),OPT.ext]);
  image(OPT.x,OPT.y,A)
  colormap(map)
  tickmap('ll');grid on;
  set(gca,'ydir','normal')
  %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
  %TODO colorbarwithvtext(OPT.layers)  
  print2screensize([mkvar(server),'_rendered'])
  end
  