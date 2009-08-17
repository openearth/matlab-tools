function M = odvread_struct2matrix(D)
%ODVREAD_STRUCT2MATRIX   transforms a struct(:) of casts to struct with 1 matrix per parameter
%
%   D = odvread_struct2matrix(R);
%
% where D contians one cast in each D(i), and 
% M contains one matrix [time x zlevels] per parameter.
% all gaps due to different zlevels per cast are filled with NaN.
% All items where datenum is NaN are removed.
%
% Example:
%
%      OPT.files     = dir(...);
%   for ifile=1:length(OPT.files)
%      OPT.filename = OPT.files(ifile).name;
%      R(ifile) = odvread([OPT.directory,filesep,OPT.filename]);
%   end
%   D = odvread_struct2matrix(R);
%
%See also: ODVREAD, ODVDISP, ODVPLOT, ODV2NC

   OPT.sort = 1; % on datenum

   %% find size for pre-alllocation
   %------------------

   %% time (remove NaNs)
   %------------------

   M.datenum                = repmat(nan,[length(D) 1]);
   for ii=1:length(D)
      M.datenum     (ii)       = D(ii).datenum     ;
   end      
   
   if OPT.sort
      [M.datenum,index] = sort(M.datenum);
   else
      index = [1:M.number_of_observations]
   end
   
   %% NaNs come at the end in the sorting routine
   %  so we can just chop the index array
   index           = find(~isnan(M.datenum)); % 1st
   M.datenum  = M.datenum(~isnan(M.datenum)) ; % 2nd

   M.number_of_observations = length(index);

   %% zlevels
   %------------------

   M.number_of_levels       = 0; 
   for ii=1:M.number_of_observations
      M.number_of_levels = max(M.number_of_levels,length(D(ii).data.datenum));
   end
   
   %% pre-allocate matrix
   %------------------
   
   M.filename               =   cell(    [M.number_of_observations 1]);
   M.cruise                 =   cell(    [M.number_of_observations 1]);
   M.station                =   cell(    [M.number_of_observations 1]);
   M.type                   =   cell(    [M.number_of_observations 1]);
   M.latitude               = repmat(nan,[M.number_of_observations 1]);
   M.longitude              = repmat(nan,[M.number_of_observations 1]);
   M.bot_depth              = repmat(nan,[M.number_of_observations 1]);
   
   M.sea_water_pressure     = repmat(nan,[M.number_of_observations M.number_of_levels]);
   M.sea_water_temperature  = repmat(nan,[M.number_of_observations M.number_of_levels]);
   M.sea_water_salinity     = repmat(nan,[M.number_of_observations M.number_of_levels]);
   M.sea_water_fluorescence = repmat(nan,[M.number_of_observations M.number_of_levels]);
   
   M.LOCAL_CDI_ID           =   cell(    [M.number_of_observations 1]);
   M.EDMO_code              =   cell(    [M.number_of_observations 1]);

   fldnames = {'sea_water_pressure',...
               'sea_water_temperature',...
               'sea_water_salinity',...
               'sea_water_fluorescence'};
               
   %% fill matrix
   %------------------
   for ii=[index(:)'] % oddity required in 7.5.0
      disp(num2str(ii))
      M.filename{ii}       = D(ii).file.name   ;
      M.cruise      {ii}       = D(ii).cruise      ;
      M.station     {ii}       = D(ii).station     ;
      M.type        {ii}       = D(ii).type        ;
      M.latitude    (ii)       = D(ii).latitude    ;
      M.longitude   (ii)       = D(ii).longitude   ;
      M.bot_depth   (ii)       = D(ii).bot_depth   ;
      M.LOCAL_CDI_ID{ii}       = D(ii).LOCAL_CDI_ID;
      M.EDMO_code   {ii}       = D(ii).EDMO_code   ;
      
      for ifld=1:length(fldnames)
         fldname = fldnames{ifld};
         number_of_levels = length(D(ii).data.(fldname));
         if number_of_levels>0
            M.(fldname)(ii,1:number_of_levels) = D(ii).data.(fldname);
         end
      end
   end

 %% EOF   