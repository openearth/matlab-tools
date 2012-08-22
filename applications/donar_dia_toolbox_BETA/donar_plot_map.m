function donar_plot_maps(donarMatFile,sensorname,thefontsize,themarkersize)
%DONAR_MULTIYEAR_BOXPLOTS Makes Box-Whiskers plots from "donarmat files"
%   with the use of DONAR_DIA2DONARMAT. 
%
%   [Qs,Ind] = DONAR_MULTIYEAR_BOXPLOTS(path2donarMatFile,sensorname)
%   where Qs is a structure containing the quantiles of the information per
%   sensor name and per month. 
%  
%   Arguments:
%   <X> x coordenates of the grid to be checked 
%   <Y> y coordenates of the grid to be checked 
%   <coord> the type of coordenates
%   See also: INPOLYGON, REDUCE2MASK

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 14.08.2012
%      Author: I. Garcia Triana
% -------------------------------------------------------------------------


    disp(['Loading: ',donarMatFile]);
    load(donarMatFile)
    
    thefields = fields(thecompend);

    the_path2file = donarMatFile(1:max(findstr(donarMatFile,'\')));
    thedir = [the_path2file,'donar_dia_TeX\figures\'];
    if ~exist(thedir), mkdir(thedir); end

    
    
    % Get the minimum and maximum date in the data series... it will be
    % usefull for names and titles. 
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)
        thecompend.(thefields{j}).data(:,4) = thecompend.(thefields{j}).data(:,4) + thecompend.(thefields{j}).referenceDate;
        minX = min(minX,min(thecompend.(thefields{j}).data(:,4)));
        maxX = max(maxX,max(thecompend.(thefields{j}).data(:,4)));
    end
    
    
                fileID = fopen([the_path2file,'donar_dia_TeX\theTeX_General.tex'],'W');
                thestr = ['\section{Spatial distribution of ',strrep(sensorname,'_',' '),' observations between ',num2str(year(minX)),' and ',num2str(year(maxX)),'}'];
                fprintf(fileID,'%s\n',thestr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % All Observations Maps %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 1:length(thefields)
        
        disp(thefields{j});
        f = figure('visible','off');
        thelineS = colormap;        
        plot_map('lonlat','color',[0.5,0.5,0.5]);   hold on;
        
        [unique_campaign,~,campaign_index] = unique(thecompend.(thefields{j}).data(:,6));

        numCamp = length(unique_campaign);
        for icampaign = 1:1:numCamp
            table_year_campaign = thecompend.(thefields{j}).data(campaign_index == icampaign,:);
            table_year_campaign = sortrows(table_year_campaign,4);

            plot(table_year_campaign(:,1),table_year_campaign(:,2),'.','color',thelineS(fix((icampaign-1)/(numCamp)*64)+1,:),'markersize',themarkersize);
            set(gca,'FontSize',thefontsize);
        end
        title(['Observations of ',strrep(thecompend.(thefields{j}).deltares_name,'_',' '),' between ',num2str(year(minX)),' - ',num2str(year(maxX))],'FontWeight','bold','FontSize',thefontsize);
        set(gca,'FontSize',thefontsize);    
        fileName = [sensorname,'_obsMap','_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        close(f);
        
                thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1.1\textwidth]{figures/',fileName,'} \end{figure}'];
                fprintf(fileID,'%s\n',thestr);
    end
    
    fclose(fileID);
end