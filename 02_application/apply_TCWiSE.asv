%% TCWise: main application script
% 'Observed' are TCs that are based on historical observations
% 'Simulated' are TCs that are synthetic simulations
%
% v1.0.78  10-02-2021  Leijnse  First externally available version of TCWiSE
%
clear all
close all
clc
warning off
tic

restoredefaultpath;
addpath(genpath('C:\Users\JABE\OneDrive - DHI\wProjects\Typhoons'))
%addpath(genpath('C:\Users\JABE\OneDrive - DHI\MatlabCode\nctoolbox_master'))

%% 1. Folder locations
foverall = 'C:\Users\JABE\OneDrive - DHI\wProjects\Typhoons\TCWiSE_toolbox_v1.0.79\'; % folder of checkout TCWiSE, to be changed by user 

% Go to TCWiSE location
cd([foverall]);

% Add TCWise scripts
addpath(genpath([foverall, '\01_scripts\']));

% Output location
setting.destout                     = 'C:\Users\JABE\OneDrive - DHI\wProjects\Typhoons\TMP'; % wanted output location, to be changed by user
mkdir(setting.destout);

%% 2. Settings - user
setting.basinid                     = 'NA';                                 % Oceanic basin of interest. Choose from 'NA'=North Atlantic,'SA'=South Atlantic,'WP'=Western Pacific,'EP'=Eastern Pacific,'SP'=Southern Pacific,'NI'=North Indian,'SI'=South Indian
setting.source                      = 'usa';                                % Data source from IBTrACS, globally the most complete and recommended data source is 'usa' (JTWC).    Other options are (see: https://www.ncdc.noaa.gov/ibtracs/index.php?name=sources) bom = Australian BoM,cma = Chinese Met. Admin., ds824 = ds824 (static library), hko = Hong Kong Observatory, mlc = M.L. Chenoweth dataset (static library), nadi = RMSC Fiji, neumann = Charlie Neumann Southern Hemisphere Data (static library), newdelhi = RSMC New Delhi, reunion = RSMC La Reunion, td9635 = TD-9635 dataset (static library), td9636 = TD-9636 dataset (static library), tokyo = RMSC Tokyo, usa = U.S. Agency (RMSC Honolulu and RSMC Miami), wellington = RMSC Wellingtion, wmo = Official WMO agency (combined with general lat/lon, 'This is merged position based on the position(s) from the various source datasets')
setting.nyears                      = 10;                                 % Total number of years to simulate
setting.dt                          = 3;                                    % Time step (in hours) for the tracks, 3 hrs is recommended
setting.start_year                  = -9999;                                % Year from which historic data is used as input; if -9999 just first one (include all data)
setting.end_year                    = -9999;                                 % Year from which historic data is used as input; if -9999 just until last one (include all data)

% Settings - user: area of interest lat/lon box (4 points) to make spiderweb files for
cyclone_files.AoIfile               = [18 -99; 18 -65; 35 -65; 35 -99];     % lower left, lower right, upper right, upper left corners

% Settings - user: Climate change effects
cyclone_files.changefrequency       = 1;                                    % 1.256 for NI based on Knutson et al. (2015) which is a 25.6% increase in frequency, changefrequency = 1 means no increase (=current climate)
cyclone_files.changeintensity       = 1;                                    % 1.016 for NI based on Knutson et al. (2015) which is a 1.6% increase in wind speed, changeintensity = 1 means no increase (=current climate)

%% 3. Settings - advanced
setting.dx                          = 1.0;                                  % Grid spacing in degrees: used for genesis (uses eye of storm)
setting.dx2                         = 0.1;                                  % grid spacing in degrees used for final wind maps (based on wes)
setting.window_KDE                  = 500;                                  % number of points needed in KDE (was 500)
setting.window_dx                   = 10;                                    % maximum box searched in (10 default)
setting.window_genesis_term         = 250;                                  % size of the genesis / termination box [km; default 250km]
setting.exclude_land_map_KDE        = [1];                                  % 1 is yes, 0 is no
setting.methodlandv_KDE             = [2];                                  % if exclude land map, 2 means we see them as 0, no effect wind speed
setting.deleteclosezeros_KDE        = [1 1 0];                              % close to zeros are used (forward, heading, vmax). 1 means delete those and 0 not.
setting.ret_per                     = [1 10 25 50 100 250 500 1000];        % Return period maps of interest

setting.merge_frac                  = 0.5;                                  % (default = 0.5, Leave away merge_frac, e.g. wanted for running in SFINCS, then put: merge_frac= [];
setting.lon_conv                    = 0;                                    % longitude data in -180:180(default, lon_conv=0) or 0-360 (lon_conv=1). Choose the latter if historical tracks in basin pass the 180 degree line
setting.change_date                 = 0;                                    % change start dates synthetic tracks to constant 1970-01-01 set to 1 if you want the dates to be changed 
setting.wind_conversion_factor      = 0.93;                                 % factor to convert wind speeds to 10-min averaged in cyclonestats_write_WES_input.m

setting.latitude_allowed    	    = [0,0,0];                              % forward, heading, vmax based on location (1) instead of latitude (0)
setting.additional_landeffect       = [1];                                  % additional decrease wind due to land based on Kaplan = 1, 0= no additional decrease and just using KDE from data
setting.coefficientdecay            = [0.0155];                             % 5 days for CAT1 to decay to 10 knots
setting.termination_method          = [1];                                  % termination method: simple (1) or complex (2)
setting.stochastic_radii            = [0 1];                                % use stochastic wind radii based on Nederhoff et al. (2019) for [observed synthetic] - 0 = mode, 1 = yes use random variability;
setting.seed                        = 0;                                    % seed value as used in rand.m functions, controlled using rng(setting.seed,'twister'), default of matlab is 0 with twister as generator

% Settings - advanced: Cutoff values
setting.cutoff_windspeed            = 10;                                   % in knots (has always been default)
setting.minimum_windspeed           = 50;                                   % in knots (has always been default)
setting.needed_windspeed            = 17;                                   % in m/s (new variable)
setting.cutoff_sst                  = -999;                                 % in celsius (for NA we used 10 knots too)

% Settings - advanced: Change coordinate system spiderwebs to projected, keyword change_cs = 1, by default it stays WGS84 (lat/lon) (=0)
setting.change_cs                   = 0;       
setting.cs.name                     = 'WGS 84 / UTM zone 15N'; 
setting.cs.type                     = 'projected'; 

% Settings - advanced: KDE
% Type
setting.kde.auto                    = 1;                                 % if 0, we use the values below = 1 we find quantile values
setting.kde.auto_steps              = [0:0.10:1.0];                     % if 0, we use the values below = 1 we find quantile values

%       Forward
setting.kde.fw_range                = [0 20];                            % min and max foreward speed
setting.kde.fw_search               = 1.0;                               % mean of the heading bin
setting.kde.forward_speed_bins      = [setting.kde.fw_range(1):setting.kde.fw_search:setting.kde.fw_range(2)];	% bins
setting.kde.forward_search_range    = setting.kde.fw_search;             % search areas = 4 knots

%       Heading
setting.kde.h_range                 = [0 360];                          % min and max heading
setting.kde.heading_step            = 22.5;                             % Search range around mean of each bin for heading
setting.kde.heading_bins            = (0:setting.kde.heading_step:360)*pi/180;  % bins
setting.kde.heading_search_range    = setting.kde.heading_step *pi/180; % 45 degrees bin 

%       Vmax
setting.kde.v_range                 = [0 200];
setting.kde.vmax_step_size          = 10;                                % Search range around mean of each bin for vmax
setting.kde.vmax_bins               = [setting.kde.v_range(1):setting.kde.vmax_step_size:setting.kde.v_range(2)];    % bins
setting.kde.vmax_search_range       = setting.kde.vmax_step_size;

%% 4. Input data
% Input data - all .ldb or .pol files should be in WGS84 in lat/lon
fmain                               = [foverall,'\02_application\data\'];
fname                               = [fmain, 'IBTrACS.ALL.v04r00_download260520.nc']; % folder of ibtracks dataset
ibtracsfile                         = fname;                                            % URL https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/netcdf/
cyclone_files.ldbplotfile           = [fmain, '\entire_world_coarse.ldb'];              % whole world ldb file for plots
setting.landfile                    = [fmain, setting.basinid,'\gebco.xyz'];            % landmasses needed for cyclone decay (xyz from DDB)
cyclone_files.sstfile               = [fmain,'\NOAA_SST.mat'];                          % monthly SST for the entire world:

% Add comparison points if wanted (remove '%' and fill in values for x1,y1 etc.)
% cyclone_files.comparison_points(:,1) = [x1, x2]; % add longitude values here
% cyclone_files.comparison_points(:,2) = [y1, y2]; % add latitude values here

%% 5. Output file names
% Output directory
dir                                 = setting.destout; 
setting.label                       = '_dx1';
mkdir(dir); cd(dir);

% Define names
cyclone_files.observed              = [dir '\ibtracs.' setting.basinid '_since' num2str(setting.start_year) setting.label '.mat'];              % local file with filtered IBTRACKS data
cyclone_files.pdffile_obs           = [dir '\pdf_historical.' setting.basinid '_since' num2str(setting.start_year)  setting.label '.mat'];     	% PDFs on grid
cyclone_files.mapsfile_obs          = [dir '\maps_historical.' setting.basinid '_since' num2str(setting.start_year)  setting.label '.mat']; 	% statistics on grid
cyclone_files.rpwind_obs            = [dir '\rp_historical.' setting.basinid  num2str(setting.nyears) 'years' setting.label '.mat'];  		% RP wind values

cyclone_files.simulated             = [dir '\simulated.' setting.basinid num2str(setting.nyears) 'years' setting.label '.mat'];         	% synthetic tracks
cyclone_files.pdffile_sim           = [dir '\pdf_simulated.' setting.basinid num2str(setting.nyears) 'years' setting.label '.mat'];     	% PDFs on grid 
cyclone_files.mapsfile_sim          = [dir '\maps_simulated.' setting.basinid  num2str(setting.nyears) 'years' setting.label '.mat'];  		% simulated tracks
cyclone_files.rpwind_sim            = [dir '\rp_simulated.' setting.basinid  num2str(setting.nyears) 'years' setting.label '.mat'];  		% RP wind values
cyclone_files.ibtracsfile           = ibtracsfile;

%% 6. Main: generate synthetic cyclones
disp(['Create synthetic TCs']);
tic

% Copy script over so we have a reference
FileNameAndLocation                 = [mfilename('fullpath')];
cd(dir);
newbackup                           = sprintf('apply_TCWiSE.m');
currentfile                         = strcat(FileNameAndLocation, '.m');
copyfile(currentfile,newbackup);

% Start my Diary
diary _myLogFile

% Generate tracks
cyclonetracks                       = cyclonestats_compute_all(cyclone_files,setting);

toc

%% 7. Write WES input files (needed for model simulations)
disp(['Write WES']);
tic
% A. Historical tracks
setting.regionID                    = findbasinnumber_radii(setting.basinid);
cyclonestats_write_WES_input(dir, 'observed', cyclone_files, setting);

% B. Synthetic / simulated tracks
if setting.change_date == 1 
    cyclonestats_write_WES_input(dir, 'simulated_SWAN', cyclone_files, setting);
else
    cyclonestats_write_WES_input(dir, 'simulated', cyclone_files, setting);
end

toc

%% Finished
disp('TCWiSE has finished');
diary off
