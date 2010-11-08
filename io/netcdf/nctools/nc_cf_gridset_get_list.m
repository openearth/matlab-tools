function nc_cf_gridset_get_list(url,varargin)
%nc_cf_gridset_get_list  list of all tiles and their times from opendap server
%
%    nc_cf_gridset_get_list(url,<keyword,value>)
%
% Example: for OpenEarth test and production server
%
% RWS Jarkus Grids: production
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html')
%
% RWS Vaklodingen: production and test
%    nc_cf_gridset_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%
% RWS Kustlidar: production and test
%    nc_cf_gridset_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%    nc_cf_gridset_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%
% A local netCDF gridset:
%    nc_cf_gridset_get_list(pwd)
%
%See also: grid_2D_orthogonal, opendap_catalog, rijkswaterstaat

   if ~odd(nargin)
   url      = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
   firstarg = 2;
   else
   firstarg = 1;
   end
   
  %OPT.xlsname = [mfilename('fullpath'),'.xls'];
   OPT.xlsname = ['nc_cf_gridset_get_list.xls'];
   
   OPT = setProperty(OPT,varargin{firstarg:end});

%% get available files

   L = opendap_catalog(url);
   L = sort(L);

%% get meta-info
%  TO DO: get bounding box too

   disp('    name                 : first date - last date  n                                                            ')
   for i=1:length(L)
       t{i} = nc_cf_time(L{i},'time');
      t0(i) = t{i}(1);
      t1(i) = t{i}(end);
      nt(i) = length(t{i});
     %disp([num2str(i,'%0.3d'),'/',num2str(length(L),'%0.3d')])
      disp([num2str(i,'%0.3d'),' ',pad(filename(L{i}),' ',-21),': ',datestr(t0(i),29),' - ',datestr(t1(i),29),' ',num2str(nt(i),'%0.2d')])
   end

%% get all available dates

   allt = [];
   for i=1:length(L)
   allt = [allt t{i}'];
   end

%% make ascii table with available years

   years = unique(year(allt));
   array =repmat('~',[length(L) length(years)]);
   mask  =repmat(0  ,[length(L) length(years)]);
   disp([url,' ', datestr(now)]);
   disp(addrowcol(num2str(years')',0,-54,' '));
   disp('#   name                 : first date - last date  n                                                            ')
   for i=1:length(L)
      [dummy,dummy,ind]=intersect(year(t{i}),years);
      array(i,ind)='#';
      mask (i,ind)=1;
      disp([num2str(i,'%0.3d'),' ',pad(filename(L{i}),' ',-21),': ',datestr(t0(i),29),' - ',datestr(t1(i),29),' ',num2str(nt(i),'%0.2d'),' ',array(i,:)])
   end
   
%% make xls table with available years
   
   S.volgnummer = 1:length(L);
   S.name       = char(L);
   S.start      = datestr(t0,'yyyy-mm-dd HH:MM:SS');
   S.end        = datestr(t1,'yyyy-mm-dd HH:MM:SS');
   S.aantal     = nt;
%%
   for i=1:length(years)
   
   varname = ['year_',(num2str(years(i)))];
   
   S.(varname) = mask(:,i);
   
   end
   
   struct2xls(OPT.xlsname,S,'header',{url,datestr(now),'Created with $nc_cf_gridset_get_list.m$'})
