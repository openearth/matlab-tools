function varargout = opendap_get_cache(varargin)
%OPENDAP_GET_CACHE  download all netcdf files from one opendap server directory
%
%    opendap_get_cache(<keyword,value>)
%
% Example:
%
% opendap_get_cache('server','http://opendap.deltares.nl/thredds/',...
%                    'local','e:\opendap\',...
%                  'dataset','/rijkswaterstaat/grainsize/',... % will be appended to both 'server' and 'local' directory
%                    'pause',1); % first time try with pause on
%
% pause = 2 pasues after every file, pause = 1 pauses only after verifying local directory
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
   OPT.pause    = 1; % default verify only directory, set to 2 to verify every file
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
   
   base_url = path2os([OPT.server           ,'/fileServer/opendap/',OPT.dataset],'h');
   base_loc = path2os([OPT.local,                                   OPT.dataset]);
   
   mkpath(base_loc)

%% find ncfiles

   list = opendap_catalog(path2os([OPT.server,'/catalog/opendap/',OPT.dataset,'/catalog.html']));
   
   if ~isempty(list)
      list = cellstr(filenameext(char(list)));

%% download all one by one

      disp(['Downloading to: '])
      disp([base_loc])
      if OPT.pause
      pausedisp
      end

      nnc = length(list);
      tic
      for inc=1:nnc
          
         ncfile = list{inc};
         fprintf(['%0.4d of %0.4d : %s '],inc,nnc,ncfile);
         if OPT.pause>1
         pausedisp
         end
          
         urlwrite(path2os([base_url,filesep,ncfile],'h'),...
                          [base_loc,filesep,ncfile]);
              
         tmp=toc;
         fprintf([' (passed time is %f s) \n'],tmp);
              
      end
   end