function [] = Vakloadingen_surf_from_repository()
%VAKLOADINGEN_SURF_FROM_REPOSITORY Summary of this function goes here
%   Detailed explanation goes here

base = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
base =     'D:/opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
dest = 'd:\kml.deltares.nl\Rijkswaterstaat\vaklodingen3d\';

tiles = {'vaklodingenKB114_4544.nc',...
         'vaklodingenKB115_4544.nc',...
         'vaklodingenKB116_4544.nc',...
         'vaklodingenKB117_4544.nc',...
         'vaklodingenKB116_4746.nc',...
         'vaklodingenKB117_4746.nc',...
         'vaklodingenKB118_4746.nc'};
 
tiles = {'vaklodingenKB113_4948.nc',...
         'vaklodingenKB114_4948.nc'};     
 
tiles = {'vaklodingenKB113_4746.nc',...
         'vaklodingenKB114_4746.nc',...
         'vaklodingenKB115_4948.nc',...         
         'vaklodingenKB115_5150.nc'};   
     
OPT.colorMap        = @(m) colormap_cpt('bathymetry_vaklodingen',m);
OPT.colorSteps      = 256;
OPT.cLim            = [-50 25];
OPT.zScaleFun       = @(z)(z+40).*50;
        
for i=1:length(tiles)    

    for LoR = [1]; % level of reduction
       url = [base,filesep,tiles{i}];
       
       D.time       = nc_cf_time(url); nt = length(D.time);
       D.z          =     ncread(url,'z',[1 1 nt],[Inf Inf 1]);
       D.x          =     ncread(url,'x');
       D.y          =     ncread(url,'y');
       
      [D.x,D.y]     = ndgrid(D.x,D.y);
      [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',28992,'CS2.code',4326);
       
       OPT.kmlName  = mktex(filename(url));
       OPT.fileName = [dest,filesep,filename(url),'_',datestr(D.time(nt),'yyyy-mm-dd'),'_',num2str(LoR),'.kmz'];
       OPT.description = ['Rijkswaterstaat vaklodingen ',datestr(D.time(nt),'yyyy-mm-dd'),' provided by OpenEarth.eu'];
       
       d = 2^LoR
       
       KMLsurf(D.lat(1:d:end,1:d:end),D.lon(1:d:end,1:d:end),D.z(1:d:end,1:d:end),OPT);
    end
    
    %%
    %OPT.fileName  = [filename(url),'_',datestr(D.time(1),'yyyy-mm-dd'),'_tiled.kmz'];
    %KMLsurf_tiled(D.lat(1:d:end,1:d:end),D.lon(1:d:end,1:d:end),D.z(1:d:end,1:d:end),OPT);
    

end


end

