function D = nc_cf_gridset_tutorial(varargin)
%NC_CF_GRIDSET_TUTORIAL  how to acces a set of netCDF tiles
%
%  D = nc_cf_gridset_tutorial(<keyword,value>)
%
% returns a struct D where every D(i) is a datasets
% with data in the box defined by keywords x and y.
%
% See also: snctools, opendap_catalog, grid_2D_orthogonal

catalog_url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html';
catalog_url = 'f:\opendap\thredds\rijkswaterstaat\kustlidar\';

%% get list of netCDF grid files from which to obtain data

nc_files  = opendap_catalog(catalog_url);

%% define bounding box of area where to get data

OPT.x       = [114019 116147 118541 116945];
OPT.y       = [572317 575643 574047 570455];
OPT.stride  = 5;
OPT.t       = datenum([2006 2010],1,1); % TO DO CHECK FOR THIS !!
OPT.epsg    = 28992; % TO DO CHECK FOR THIS !!

plot(OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]),'r')

hold on

%% loop all tiles

n = 0; % nr of datasets in bounding box

for i=1:length(nc_files)

   nc_file = nc_files{i};

   disp(['processing: ',nc_file])
   
   S.x       = nc_actual_range(nc_file,'x');
   S.y       = nc_actual_range(nc_file,'y');
   S.datenum = nc_cf_time     (nc_file);
   
   %% check whether any part of our search box is inside this tile
   %  or this tile is inside the search box
   
   if any(inpolygon(  S.x([1 2 2 1 1]),  S.y([1 1 2 2 1]),...
                    OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]))) | ... % large area of interest, small data tile (need to aggregate)
      any(inpolygon(OPT.x([1 2 2 1 1]),OPT.y([1 1 2 2 1]),...
                      S.x([1 2 2 1 1]),  S.y([1 1 2 2 1])))       % small area of interest, large data tile (need to subset   )
      
      n = n + 1;
   
      plot( S.x([1 2 2 1 1]), S.y([1 1 2 2 1]),'color','g')
      
      pausedisp

      for it=1 %:length(D.datenum)
      
         D(n).name    = nc_file;
         D(n).datenum = S.datenum(it);
         D(n).x       = nc_varget(nc_file,'x',       [0],    [ -1],             [OPT.stride]);
         D(n).y       = nc_varget(nc_file,'y',       [0],    [ -1],             [OPT.stride]);
         D(n).z       = nc_varget(nc_file,'z',[it-1 0 0],[1 -1 -1],[1 OPT.stride OPT.stride]);
      
         pcolorcorcen(D(n).x,D(n).y,D(n).z);
         
         hold on
      
      end % time
   
   else   % bounding box
   
      plot( S.x([1 2 2 1 1]), S.y([1 1 2 2 1]),'color',[.5 .5 .5])
      
   end    % bounding box

end % tiles

axis equal
grid on
tickmap('xy')
colorbar
