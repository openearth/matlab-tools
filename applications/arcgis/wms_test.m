SET.plot = 0; % 0 for catalogue onyl, 1 to download wms (SLOW)
%% USA Minnesota state aerial imagery: OK
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
  
%% GEBCO: OK
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
  
 %% THREDDS  MyOcean: use color range
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
  
 %% THREDDS  bathy: something goes wrong with |lat| > 45
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