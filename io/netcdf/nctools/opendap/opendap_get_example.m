function opendap_get_example(varargin)
%OPENDAP_GET_EXAMPLE   download all netcdf files from opendap server
%
%See also: opendap_catalog, snctools

%% specify

   OPT.server   = 'http://opendap.deltares.nl/thredds/';
   OPT.dataset  = 'rijkswaterstaat/vaklodingen';
   OPT.base_url = [OPT.server           ,'/fileServer/opendap/',OPT.dataset];
   OPT.base_loc = ['F:\opendap\thredds\',                       OPT.dataset];

%% find ncfiles

   list = opendap_catalog(path2os([OPT.server,'/catalog/opendap/',OPT.dataset,'/catalog.html']));
   list = cellstr(filenameext(char(list)));

%% download all one by one

   nnc = length(list);
   tic
   for inc=1:nnc
       
      disp([num2str(inc,'%0.3d'),' of ',num2str(nnc,'%0.3d')])
       
      ncfile = list{inc};
      urlwrite(path2os([OPT.base_url,filesep,ncfile],'h'),...
                       [OPT.base_loc,filesep,ncfile]);
           
      toc
      pausedisp
           
   end        