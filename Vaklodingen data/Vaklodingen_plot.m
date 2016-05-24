function [] = Vaklodingen_plot()
%VAKLODINGEN_PLOT Loading the data and present the data in figures
%   Detailed explanation goes here
%   
%   Last update: 24-05-2016
%   S.W. van Til
%   swvantil@gmail.com, s.w.vantil@student.tudelft.nl,
%   sjoerdwillem.vantil@deltares.nl

tiles = {'vaklodingenKB127_1312.nc',...
         'vaklodingenKB128_1312.nc',...
         'vaklodingenKB128_1514.nc',...
         'vaklodingenKB129_1312.nc',...
         'vaklodingenKB129_1514.nc'};

D.test = ncread(tiles{1},'test')
%      ,[1,1,inf],[inf,inf,1]
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
%      
%      
% OPT.colorMap        = @(m) colormap_cpt('bathymetry_vaklodingen',m);
% OPT.colorSteps      = 256;
% OPT.cLim            = [-50 25];
% OPT.zScaleFun       = @(z)(z+40).*50;
% 
% for i=1:length(tiles)
%     
%     for LoR = [1]; % level of reduction
%        url = [tiles{i}];
%        
%        D.time       = nc_cf_time(url); nt = length(D.time);
%        D.z          =     ncread(url,'z',[1 1 nt],[Inf Inf 1]);
%        D.x          =     ncread(url,'x');
%        D.y          =     ncread(url,'y');
%        
% %       [D.x,D.y]     = ndgrid(D.x,D.y);
% %       [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',28992,'CS2.code',4326);
% %        
% %        OPT.kmlName  = mktex(filename(url));
% %        OPT.fileName = [dest,filesep,filename(url),'_',datestr(D.time(nt),'yyyy-mm-dd'),'_',num2str(LoR),'.kmz'];
% %        OPT.description = ['Rijkswaterstaat vaklodingen ',datestr(D.time(nt),'yyyy-mm-dd'),' provided by OpenEarth.eu'];
% %        
% %        d = 2^LoR
% %        
% %        KMLsurf(D.lat(1:d:end,1:d:end),D.lon(1:d:end,1:d:end),D.z(1:d:end,1:d:end),OPT);
%     end
%     
% end




end

