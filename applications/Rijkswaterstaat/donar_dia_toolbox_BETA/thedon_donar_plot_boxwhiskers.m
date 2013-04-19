function thedon_donar_plot_boxwhiskers
% thedon_donar_plot_boxwhiskers Box and Whisker diagram for all observations in TIME (MONTHS)

    thedonarfiles = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2008_the_compend.mat'}

    ctd_cont   = 1;
    ferry_cont = 1;
    scan_cont  = 1;
    
    variable = 'turbidity';
    
    for i = 1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        donarMat = importdata(thedonarfiles{i});
        
        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 

            if ctd_cont == 1
                ctd.(variable) = donarMat.(variable);
            else
                ctd.(variable).data = [ctd.(variable).data; donarMat.(variable).data];
            end
            
            ctd_cont = ctd_cont+1;
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
            
            if ferry_cont == 1
                ferry.(variable) = donarMat.(variable);
            else
                ferry.(variable).data = [ferry.(variable).data; donarMat.(variable).data];
            end
            
            ferry_cont = ferry_cont+1;
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
            
            if scan_cont == 1
                scan.(variable) = donarMat.(variable);
            else
                scan.(variable).data = [scan.(variable).data; donarMat.(variable).data];
            end
            
            scan_cont = scan_cont+1;
        end
        
        clear donarMat
    end
    
%%
close all

    donar_plot_boxwhiskers(ctd,variable,'CTD',20);
    ylabel(['Upoly0 [-]'])
    fileName = ['boxplot_CTD_turbidity'];
    print('-dpng',fileName);
    
    donar_plot_boxwhiskers(ferry,variable,'FerryBox',20);
    fileName = ['boxplot_FerryBox_turbidity'];
    print('-dpng',fileName);
       
    ferry_clipped = ferry;
    ferry_clipped.(variable).data( ferry_clipped.(variable).data(:,5) > 2.9, : ) = [];
    donar_plot_boxwhiskers(ferry_clipped,variable,'FerryBox',20);
    fileName = ['boxplot_FerryBox_turbidity_0-3'];
    print('-dpng',fileName);
    
    donar_plot_boxwhiskers(scan,variable,'ScanFish',20);
    ylabel(['Upoly0 [-]'])
    fileName = ['boxplot_ScanFish_turbidity'];
    print('-dpng',fileName);
