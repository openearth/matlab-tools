%% Read the data from the matlab file and produce a NetCDF.
% thedon_donarmat2NC Read the data from the matlab file and produce a NetCDF.
%
% The structure is organized by observed parameter. 





clc; clear;



%% GENERATION OF NETCDF FILE:

    % Now it is not necessary, but remember to load the mat file if
    % you are not running the first part of this script or you want to
    % avoid running it.
                 
    files_to_convert = { ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2005_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2006_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2007_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2008_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
    'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
    };

    for ifile = 1:1:length(files_to_convert)
        
                
        %%%%%%%%%%%%%%%%%%%%%%%%
        % Load the Information %
        %%%%%%%%%%%%%%%%%%%%%%%%
        disp(['Loading: ', files_to_convert{ifile}]);
        thecompend  = importdata(files_to_convert{ifile});
        
        
        
        %%%%%%%%%%%%%%%%%%%%%
        % Folder for Saving %
        %%%%%%%%%%%%%%%%%%%%%
        the_filename = files_to_convert{ifile}(1:max(strfind(files_to_convert{ifile},'_the_compend.mat'))-1)
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Produce the NetCDF File %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        donar_donarMat2nc(thecompend,the_filename);

        % It turns out that this memory might be necessary for the next
        % iteration. 
        clear thecompend;
    end    