%GETWATERBASEDATAWATERSTAND   download waterbase data for one parameter for all stations for selected time period 
%
% See also: GETWATERBASEDATA, DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>,  
%           GETWATERBASEDATA_SUBSTANCES, GETWATERBASEDATA_LOCATIONS


% CodeName :1%7CWaterhoogte+in+cm+t.o.v.+normaal+amsterdams+peil+in+oppervlaktewater"
% FullName :Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater
% Code     :1
% indSub   :654
% 
% indLoc   :1:239

   OPT.Code          = 1;
   OPT.standard_name = 'sea_surface_height'; % http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   OPT.directory.raw = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\';
   OPT.period        = datenum([1961 2008],1,1);
   OPT.nc            = 0; % not implemented yet
   OPT.opendap       = 0; % not implemented yet
   
%% Match and check Substance
% --------------------------------

   SUB        = getWaterbaseData_substances;
   OPT.indSub = find(SUB.Code==OPT.Code);

   disp(['--------------------------------------------'])
   disp(['indSub   :',num2str(             OPT.indSub )])
   disp(['CodeName :',        SUB.CodeName{OPT.indSub} ])
   disp(['FullName :',        SUB.FullName{OPT.indSub} ])
   disp(['Code     :',num2str(SUB.Code    (OPT.indSub))])

%% get and check Locations
% --------------------------------

   LOC = getWaterbaseData_locations(SUB.Code(OPT.indSub));
   
   if ~exist([OPT.directory.raw,filesep,OPT.standard_name])
      mkdir([OPT.directory.raw,filesep,OPT.standard_name])
   end

   for indLoc=1:length(LOC.ID)
   
      disp(['----------------------------------------'])
      disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
      disp(['FullName :',        LOC.FullName{indLoc} ])
      disp(['ID       :',        LOC.ID{indLoc} ])
      
      getWaterbaseData(SUB.Code(OPT.indSub),LOC.ID{indLoc},...
                       OPT.period,...
                      [OPT.directory.raw,filesep,OPT.standard_name])   
   end
   
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

%% EOF