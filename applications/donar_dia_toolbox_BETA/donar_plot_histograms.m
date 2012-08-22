function donar_plot_histograms(donarMatFile,sensorname)
    
    disp(['Loading: ',donarMatFile]);
    load(donarMatFile);
    
    
    % Get the fields... those are the substances
    thefields = fields(thecompend);
    
    
    % Get the parent path to the file... to make things a bit clearer
    the_path2file = donarMatFile(1:max(findstr(donarMatFile,'\')));
    
    
    % Create a TeX file where the figures are going to be produced
    thedir = [the_path2file,'donar_dia_TeX\figures\'];
    mkdir(thedir);
        
    
    
    minX = now;
    maxX = datenum('01-Jan-1800');
    for j = 1:length(thefields)
        
        thecompend.(thefields{j}).data(:,4) = thecompend.(thefields{j}).data(:,4) + thecompend.(thefields{j}).referenceDate;
        
        minX = min(minX,min(thecompend.(thefields{j}).data(:,4)));
        maxX = max(maxX,max(thecompend.(thefields{j}).data(:,4)));
    end
    
    
    fileID = fopen([the_path2file,'donar_dia_TeX\theTeX_General.tex'],'W');
       
    
    %%%%%%%%%%%%%%
    % TIMESERIES %
    %%%%%%%%%%%%%%
    f = figure('visible','off');
    for j = 1:length(thefields)
        disp(thefields{j});
        hsp = subplot(ceil(length(thefields)/2),2,j);

        plot(thecompend.(thefields{j}).data(:,4),thecompend.(thefields{j}).data(:,5),'.k','markersize',5);

        xlim([minX-100,maxX+100]);
        datetick(gca,'x','mmm yyyy','keeplimits','keepticks');
        title(['Time Plot of ',strrep(thecompend.(thefields{j}).deltares_name,'_',' '),' values.'],'FontWeight','bold','FontSize',6);
        set(gca,'FontSize',6);    
    end
    fileName = [sensorname,'_timePlot','_',num2str(year(minX)),'-',num2str(year(maxX))];
    print('-depsc2',[thedir,fileName]);
    print('-dpng',[thedir,fileName]);
    
    disp(['File: ',fileName,' -> Time Plot. -- SAVED']);
    
    thestr = ['\section{Time series of ',strrep(sensorname,'_',' '),' between ',num2str(year(minX)),' and ',num2str(year(maxX)),'}'];
    fprintf(fileID,'%s\n',thestr);
    thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1.1\textwidth]{figures/',fileName,'} \end{figure}'];
    fprintf(fileID,'%s\n',thestr);
    close(f);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Observations per year map %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numCruises = max(thecompend.(thefields{j}).data(:,6));
    for j = 1:length(thefields)
        
        % Get the unique years from the data
        [unique_year,~,year_index] = unique(year(thecompend.(thefields{j}).data(:,4)));
        numYears = length(unique_year);

        
        f = figure('visible','off');
        thelineS = colormap;
        for iyear = 1:1:numYears

            % Lets focus on that data alone
            table_year = thecompend.(thefields{j}).data(year_index==iyear,:);
            
            subplot(3,ceil(numYears/3),iyear);
            plot_map('lonlat','color',[0.5,0.5,0.5]);   hold on;

            [unique_campaign,~,campaign_index] = unique(table_year(:,6));
            numCamp = length(unique_campaign);
            for icampaign = 1:1:numCamp
                table_year_campaign = table_year(campaign_index == icampaign,:);
                table_year_campaign = sortrows(table_year_campaign,4);

                plot(table_year_campaign(:,1),table_year_campaign(:,2),'.','color',thelineS(fix((icampaign-1)/(numCamp)*64)+1,:),'markersize',4);
                set(gca,'FontSize',6);
            end
            title(['Observations of ',strrep(thecompend.(thefields{j}).deltares_name,'_',' '),' in ',num2str(unique_year(iyear))],'FontWeight','bold','FontSize',6);

            set(gca,'FontSize',6);
        end
        fileName = [sensorname,'_themap','_',num2str(year(minX)),'-',num2str(year(maxX)),'_',thecompend.(thefields{j}).deltares_name];
        print('-depsc2',[thedir,fileName]);
        print('-dpng',[thedir,fileName]);
        
        disp(['File: ',fileName,' -> Map. -- SAVED'])
        
        thestr = ['\section{Maps of ',strrep(sensorname,'_',' '),' between ',num2str(year(minX)),' and ',num2str(year(maxX)),'}'];
        fprintf(fileID,'%s\n',thestr);
        
        thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1.1\textwidth]{figures/',fileName,'} \end{figure}'];
        fprintf(fileID,'%s\n',thestr);
        close(f);
    end

    
    
    %%%%%%%%%%%%%%
    % HISTOGRAMS %
    %%%%%%%%%%%%%%
    f = figure('visible','off');
    for j = 1:length(thefields)
        subplot(ceil(length(thefields)/2),2,j);
      
     % ->
        hist(thecompend.(thefields{j}).data(:,5),100,'facecolor','k');

        elmax = max(thecompend.(thefields{j}).data(:,5));
        elmin = min(thecompend.(thefields{j}).data(:,5));
        numreg = length(thecompend.(thefields{j}).data(:,5));
        xlabel(['Bounds: [',num2str(elmin),',',num2str(elmax),']  -  Size: ',num2str(numreg)],'FontSize',6);
        title(['Histogram of ',strrep(thecompend.(thefields{j}).deltares_name,'_',' '),' values'],'FontWeight','bold','FontSize',6);
        set(gca,'FontSize',6);
    end
    fileName = [sensorname,'_thehist','_',num2str(year(minX)),'-',num2str(year(maxX))];
    print('-depsc2',[thedir,fileName]);
    print('-dpng',[thedir,fileName]);
    disp(['File: ',fileName,' -> Histogram. -- SAVED'])
    
    thestr = ['\section{Histograms of ',strrep(sensorname,'_',' '),' between ',num2str(year(minX)),' and ',num2str(year(maxX)),'}'];
    fprintf(fileID,'%s\n',thestr);
        
    thestr = ['\begin{figure}[htbp] \centering \includegraphics[width=1.1\textwidth]{figures/',fileName,'} \end{figure}'];
    fprintf(fileID,'%s\n',thestr);
    close(f);
    
    fclose(fileID);
end