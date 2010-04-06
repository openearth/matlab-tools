function nan=ARC_INFO_BINARY2KML
%ARC_INFO_BINARY2KML   save arc_info_binary file as kml
%
%See also: ARC_INFO_BINARY, ARCGISREAD, KMLFIG2PNG

  clc
 clear all
fclose all;

%% Test data 
% All data files in
%    F:\checkouts\OpenEarthRawData\
% are a Subversion checkout from:
%    http:repos.deltares.nl/repos/OpenEarthRawData/trunk/

maps = {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007',... % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007'};   % 3

ascii= {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007\rastert_dz10_ju.txt',...  % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007\rastert_dz50_ju1.txt',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007\rastert_dz90_ju1.txt',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007\rastert_grind_f1.txt',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007\rastert_slib_ju1.txt'};   % 3

epsg = [32631 % 'WGS 84 / UTM zone 31N'
        32631
        32631
        32631
        32631];

clims= [100 400
        100 400
        100 400
          0 100
          0 100];

lgnd = {'Grain size small d10 [micrometer]',...
        'Grain size median d50 [micrometer]',...
        'Grain sizes large d90 [micrometer]',...
        'Pebbles [%]',...
        'Mud [%]'};

for im= 1:5 %:length(maps)

   close all

   [X,Y,D,M] = arc_info_binary([maps{im},'\'],...
        'debug',0,...
         'plot',0,...
       'export',1,...
        'clim',clims(im,:),...
        'epsg',epsg(im),...
          'vc','F:\checkouts\OpenEarthRawData\deltares\landboundaries\processed\northsea.nc');
       disp(['succes: ',num2str(im),' ',maps{im}]);
       succes(im) = 1;
       
   %A = ArcGisRead(ascii{im})       
       
   [X,Y] = meshgrid(X,Y);
   
   [lon,lat]=convertCoordinates(X,Y,'CS1.code',epsg(im),'CS2.code',4326);
   
   clear X Y
 
   h = pcolorcorcen(lon,lat,D);
   
   caxis(clims(im,:));
   
   KMLfig2png(h,...
        'levels',[-2 4],...
      'fileName',[last_subdir(maps{im}),'.kml'],...
   'description',[lgnd{im},'. data: <a href="http://www.tno.nl/bouw_en_ondergrond/"> TNO bouw en ondergrond</a>, plot: <a href="http://www.OpenEarth.eu"> OpenEarthTools</a> financed by <a href="http://www.ecoshape.nl"> Ecoshape</a>.']);

end
