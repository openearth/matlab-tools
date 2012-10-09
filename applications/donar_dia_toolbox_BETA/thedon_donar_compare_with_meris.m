%% COMPARE DONAR DIA DATA AND MERIS

    clc, %clear;

    addpath('d:\Dropbox\Deltares\Matlab\donar_dia_toolbox_BETA\utilities\')
    
if false
    the_meris_files = dirrec('p:\1204561-mos3\data\RemoteSensing\MERIS2WAQ\MERIS2WAQ_V03\','.map')';
    the_meris_files(~cellfun('isempty',strfind(the_meris_files,'bin'))) = []; % Remove some undesired files
    
    the_donar_files = { ...
        
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2009_the_compend.mat'; ...
    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...    
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2009_the_compend.mat'; ...   doesn't have information aboutturbidity
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2005_the_compend.mat'; ...  
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2008_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2009_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2010_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2011_the_compend.mat'; ... 
        %'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2012_the_compend.mat' ...
        };
        

    the_grid_file = 'd:\Dropbox\Deltares\Matlab\donar_dia_toolbox_BETA\utilities\grid_zuno_dd.lga'; 

    donar_compare_with_meris(the_donar_files,the_meris_files,the_grid_file,'turbidity')
end  
%%    
    clear
    close all
    
    compare_donar_meris_files = {...
                        'donar_meris_Ferrybox_2005_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2006_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2007_turbidity.mat'; ...
                        'donar_meris_Ferrybox_2008_turbidity.mat'; ...

                        'donar_meris_CTD_2003_turbidity.mat'; ...
                        'donar_meris_CTD_2004_turbidity.mat'; ...
                        'donar_meris_CTD_2005_turbidity.mat'; ...
                        'donar_meris_CTD_2006_turbidity.mat'; ...
                        'donar_meris_CTD_2007_turbidity.mat'; ...

                        'donar_meris_Meetvis_2003_turbidity.mat'; ...
                        'donar_meris_Meetvis_2004_turbidity.mat'; ...
                        'donar_meris_Meetvis_2005_turbidity.mat'; ...
                        'donar_meris_Meetvis_2006_turbidity.mat'; ...
                        'donar_meris_Meetvis_2007_turbidity.mat'; ...
                        'donar_meris_Meetvis_2008_turbidity.mat'} 
    
    sensors = {'CTD';'FerryBox';'ScanFish'};
    cont_ctd       = 1;
    cont_scanfish  = 1;
    cont_ferrybox  = 1;
    
    for ifile=1:length(compare_donar_meris_files)
        
        disp(['Loading: ',compare_donar_meris_files{ifile}]);
        thefile = importdata(compare_donar_meris_files{ifile});
        
        if strfind(lower( compare_donar_meris_files{ifile}),'ctd'),           

            sensor = sensors{1};
            if cont_ctd == 1,       ctd = thefile;
            else                    ctd = [ctd; thefile];
            end    
            cont_ctd = cont_ctd + 1;
            
        elseif strfind(lower( compare_donar_meris_files{ifile}),'ferrybox'),  
            
            sensor = sensors{2};
            if cont_ferrybox == 1,  ferrybox = thefile;
            else                    ferrybox= [ferrybox; thefile];
            end    
            cont_ferrybox = cont_ferrybox + 1;
            
        elseif strfind(lower( compare_donar_meris_files{ifile}),'meetvis'),  
            
            
            sensor = sensors{3};
            if cont_scanfish == 1,  scanfish = thefile;
            else                    scanfish = [scanfish; thefile];
            end    
            cont_scanfish = cont_scanfish + 1;
            
        end
    end

    figure
    plot(ferrybox(:,3),ferrybox(:,4),'.b',scanfish(:,3),scanfish(:,4),'.g',ctd(:,3),ctd(:,4),'.r')
    legend('Ferrybox','ScanFish','CTD'); 
    axis square;
    ylabel('MERIS','fontsize',16);
    set(gca,'fontsize',16)
    
%%    
    figure
    set(gcf,'position',[3 225 1637 473])
    set(gcf,'PaperPositionMode','auto')
    
    subplot(1,3,1)
    plot(ctd(:,3),ctd(:,4),'.r','markersize',20)
    thefit  = polyfit(ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,3),ctd( ~isnan(ctd(:,3)) & ~isnan(ctd(:,4)) ,4),1)
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*CTD',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('CTD','fontsize',16);
    axis square;
    set(gca,'fontsize',12)
    
    
    subplot(1,3,2)
    
    plot(ferrybox(:,3),ferrybox(:,4),'.b','markersize',20)
    thefit  = polyfit(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,3),ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,4),1)
    corrcoef(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,3),ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) ,4))
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*FB',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('FerryBox','fontsize',16);
    xlim(ylim)
    axis square;
    set(gca,'fontsize',12)
    
    subplot(1,3,3)
    plot(scanfish(:,3),scanfish(:,4),'.g','markersize',20)
    thefit  = polyfit(scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3),scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4),1)
    corrcoef(scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,3),scanfish( ~isnan(scanfish(:,3)) & ~isnan(scanfish(:,4)) ,4))
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*SF',num2str(thefit(2),'%+6.4f')])
    
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('ScanFish','fontsize',16);
    axis square;
    set(gca,'fontsize',12)
    print('-dpng','donar_vs_meris');
    
    
    %%
    
    figure
    set(gcf,'position',[360   278   560   420])
    set(gcf,'PaperPositionMode','auto')
    
    plot(ferrybox(ferrybox(:,3)<5,3),ferrybox(ferrybox(:,3)<5,4),'.b','markersize',20)
    thefit  = polyfit(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<5 ,3), ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<5 ,4),1)
    corrcoef(ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<5 ,3), ferrybox( ~isnan(ferrybox(:,3)) & ~isnan(ferrybox(:,4)) & ferrybox(:,3)<5 ,4) )
    hold on
    plot([0;max(xlim)],[thefit(2),thefit(1)*max(xlim)+thefit(2)], '-.k')
    legend('Observations',['meris = ',num2str(thefit(1)),'*FB',num2str(thefit(2),'%+6.4f')])
    ylabel('MERIS [mg/l]','fontsize',16);
    xlabel('FerryBox','fontsize',16);
    axis square;
    set(gca,'fontsize',12)
    print('-dpng','ferrybox_vs_meris');