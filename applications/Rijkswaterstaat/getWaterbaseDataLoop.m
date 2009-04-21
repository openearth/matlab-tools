%GETWATERBASEDATALOOP   script to download waterbase data for one parameter for all stations for a selected time period 
%
% See also: GETWATERBASEDATA, DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>,  
%           GETWATERBASEDATA_SUBSTANCES, GETWATERBASEDATA_LOCATIONS, GETWATERBASE2NC_TIME_DIRECT

%% Choose parameter and provide CF standard_names.
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
%------------------

   OPT.Codes          = 1;
   OPT.standard_names = 'sea_surface_height';

   OPT.Codes          = 54;
   OPT.standard_names = 'sea_surface_height';

   OPT.Codes          = 410;
   OPT.standard_names = 'concentration_of_suspended_matter_in_sea_water';

   OPT.codes          = [44 
                         559 
                         22 
                         23 
                         24];

   OPT.standard_names = {'sea_surface_temperature',...
                         'sea_surface_salinity',...
                         'sea_surface_wave_significant_height',...
                         'sea_surface_wave_from_direction',...
                         'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};
                         
%% Initialize
%------------------

   OPT.directory.raw = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\raw\';

   OPT.period        = datenum([1961 2008],1,1);
   OPT.zip           = 1; % zip txt file and delete it
   OPT.nc            = 0; % not implemented yet
   OPT.opendap       = 0; % not implemented yet
   
%% Parameter loop
%------------------

for ivar=1:length(OPT.codes)

   OPT.code           = OPT.codes(ivar);
   OPT.standard_name  = OPT.standard_names{ivar};

   %% Match and check Substance
   %---------------------------------
   
      SUB        = getWaterbaseData_substances;
      OPT.indSub = find(SUB.Code==OPT.code);
   
      disp(['--------------------------------------------'])
      disp(['indSub   :',num2str(             OPT.indSub )])
      disp(['CodeName :',        SUB.CodeName{OPT.indSub} ])
      disp(['FullName :',        SUB.FullName{OPT.indSub} ])
      disp(['Code     :',num2str(SUB.Code    (OPT.indSub))])
   
   %% get and check Locations
   %---------------------------------
   
      LOC = getWaterbaseData_locations(SUB.Code(OPT.indSub));
      
      if ~exist([OPT.directory.raw,filesep,OPT.standard_name])
         mkdir([OPT.directory.raw,filesep,OPT.standard_name])
      end
   
      for indLoc=1:length(LOC.ID)
      
         disp(['----------------------------------------'])
         disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
         disp(['FullName :',        LOC.FullName{indLoc} ])
         disp(['ID       :',        LOC.ID{indLoc} ])
         
         OPT.filename = ...
         getWaterbaseData(SUB.Code(OPT.indSub),LOC.ID{indLoc},...
                          OPT.period,...
                         [OPT.directory.raw,filesep,OPT.standard_name]);
      %% Zip
      %----------------------
   
         if OPT.zip
            zip   (OPT.filename,OPT.filename);
            delete(OPT.filename)
         end
         
      end % for indLoc=1:length(LOC.ID)
      
   %% Transform to *.nc files
   %----------------------
   
      if OPT.nc
      for indLoc=1:length(LOC.ID)
        %getWaterbase2nc_time_direct(OPT.standard_name,directory.raw,directory.nc)
      end
      end
      
   %% Copy to OPeNDAP server 
   %----------------------
   
      if OPT.opendap
      for indLoc=1:length(LOC.ID)
        %filecopy(...)
      end
      end

end % for ivar=1:length(OPT.codes)

%% EOF