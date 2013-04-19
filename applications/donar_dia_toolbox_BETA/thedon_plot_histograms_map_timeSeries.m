function thedon_plot_histograms_map_timeSeries
%thedon_plot_histograms_map_timeSeries Make time plots and histograms.
    
     files_of_interest = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2003_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2004_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2008_the_compend.mat'; ...
                  
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2008_the_compend.mat'; ...
        
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
    };

    warning off;

    for ifile = 1:1:length(files_of_interest)

        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(files_of_interest{ifile}),'ferry')
            sensor_name = 'FerryBox';
        elseif strfind(lower(files_of_interest{ifile}),'meetvis')
            sensor_name = 'ScanFish';
        end
    
 
%          year = donar_plot_histograms(files_of_interest{ifile},'turbidity',12);
%          if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
%              title(['Upoly0 ',datestr(year,'yyyy')],'fontweight','bold')
%              legend(sensor_name,'location','northwest')
%          else
%              legend(sensor_name,'location','northeast')
%          end
%          ylabel('Number of Measurements')
%          fileName = ['d:\Dropbox\Deltares\MoS-3\Garcia Report\figures\histograms\thehist_',sensor_name,'_',datestr(year,'yyyy'),'.png'];
%          print('-dpng',[fileName]);
%          disp(['File: ',fileName,' -> Histogram. -- SAVED'])        
%          close
       
        if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
            thelineS = colormap;
        else
            thelineS = (colormap);
        end
        donarMat = importdata(files_of_interest{ifile});
        year = donar_plot_map(donarMat,'turbidity',12,thelineS);
        if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
            title([sensor_name,': Upoly0 [-] ',datestr(year,'yyyy')],'fontweight','bold')
        else
            title([sensor_name,': Turbidity [NTU] ',datestr(year,'yyyy')],'fontweight','bold')
        end
        %fileName = ['d:\Dropbox\Deltares\MoS-3\Garcia Report\figures\maps_per_year_x_month\themap_',sensor_name,'_',datestr(theyear,'yyyy'),'.png'];
        
        %print('-dpng',fileName);
        %disp(['File: ',fileName,' -> Map. -- SAVED'])
%         close(f);
        
%         year = donar_plot_timeSeries(files_of_interest{ifile},'turbidity',12);
%         title(datestr(year,'yyyy'),'fontweight','bold')
%         if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
%             ylabel('Upoly0')
%             legend(sensor_name,'location','best')
%         else
%             ylabel('Turbidity')
%             legend(sensor_name,'location','best')
%         end
%         fileName = ['d:\Dropbox\Deltares\MoS-3\Garcia Report\figures\time_plots\timePlot_',sensor_name,'_',datestr(year,'yyyy'),'.png'];
%         print('-dpng',fileName);
%         disp(['File: ',fileName,' -> Time Plot. -- SAVED']);
%         close
    end