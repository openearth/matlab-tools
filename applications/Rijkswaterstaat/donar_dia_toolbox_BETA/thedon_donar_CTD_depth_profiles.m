function thedon_donar_CTD_depth_profiles
% thedon_donar_CTD_depth_profiles

    files_of_interest = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...
    };

    warning off;
    
% -> Specify names of sensors:
    sensors = {'CTD';'FerryBox';'ScanFish'};
    
    for ifile=1:length(files_of_interest)
        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor      = sensors{1};
        elseif strfind(lower(files_of_interest{ifile}),'ferrybox')
            sensor      = sensors{2};
        elseif strfind(lower(files_of_interest{ifile}),'scanfish')
            sensor      = sensors{3};
        end
        
        disp(['Loading: ',files_of_interest{ifile}]);
        thefile = importdata(files_of_interest{ifile});
                
        fig_name = ['depth_profiles_',files_of_interest{ifile}(max(strfind(files_of_interest{ifile},'\'))+1:strfind(files_of_interest{ifile},'_the_compend.mat')-1)];
        
        donar_depth_profiles(thefile,'turbidity',fig_name)
        
    end