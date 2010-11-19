function varargout = opendap_get_cache(varargin)
%OPENDAP_GET_CACHE  download all netcdf files from one opendap server directory
%
%    opendap_get_cache(<keyword,value>)
%
% Example:
%
% opendap_get_cache('server','http://opendap.deltares.nl/thredds/',...
%                  'dataset','/rijkswaterstaat/grainsize/',...
%                    'local','e:\opendap\');
%
% Creates a cache of all netCDF files in:
%   http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/grainsize/
% into :
%   E:\opendap\rijkswaterstaat\grainsize\
%
%See also: OPENDAP_CATALOG, SNCTOOLS

%% specify

   OPT.server   = 'http://opendap.deltares.nl/thredds/';
   OPT.local    = '';
   OPT.dataset  = '';
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setProperty(OPT,varargin);
   
   base_url = path2os([OPT.server           ,'/fileServer/opendap/',OPT.dataset],'h');
   base_loc = path2os([OPT.local,                                   OPT.dataset]);
   
   mkpath(base_loc)

%% find ncfiles

   list = opendap_catalog(path2os([OPT.server,'/catalog/opendap/',OPT.dataset,'/catalog.html']));
   
   if ~isempty(list)
      list = cellstr(filenameext(char(list)));

%% download all one by one

      nnc = length(list);
      tic
      for inc=1:nnc
          
         disp([num2str(inc,'%0.3d'),' of ',num2str(nnc,'%0.3d')])
          
         ncfile = list{inc};
         urlwrite(path2os([base_url,filesep,ncfile],'h'),...
                          [base_loc,filesep,ncfile]);
              
         toc
         pausedisp
              
      end
   end