function donar_plot_histograms_map_timeSeries(donarMat,variable,sensorname,thefontsize)
    
    if ischar(donarMat)
        disp(['Loading: ',donarMat]);
        donarMat = importdata(donarMat);
    elseif ~isstruct(donarMat)
        error('Unrecognized input type for donarMat')
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
    
    minX = now;
    maxX = datenum('01-Jan-1800');
            
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;

    minX = min(minX,min(donarMat.(variable).data(:,4)));
    maxX = max(maxX,max(donarMat.(variable).data(:,4)));
       
    
    %%%%%%%%%%%%%%
    % TIMESERIES %
    %%%%%%%%%%%%%%
    f = figure('visible','off');
    set(gcf,'position',[398   680   722   268])
    set(gcf,'PaperPositionMode','auto')
    
    disp(variable);
    plot(donarMat.(variable).data(:,4),donarMat.(variable).data(:,5),'.b','markersize',10);
    xlim([minX-10,maxX+10]);
    datetick(gca,'x','mmm','keeplimits','keepticks');
    title([strrep([upper(donarMat.(variable).deltares_name(1)),lower(donarMat.(variable).deltares_name(2:end))],'_',' '),' ',num2str(year(minX))],'FontWeight','bold','FontSize',thefontsize);
    set(gca,'FontSize',thefontsize);    
    
    fileName = ['timePlot','_',sensorname,'_',num2str(year(minX))];
    print('-dpng',fileName);
    disp(['File: ',fileName,' -> Time Plot. -- SAVED']);
    close(f);

    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Observations per year map %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numCruises = max(donarMat.(variable).data(:,6));
    [unique_month,~,month_index] = unique(month(donarMat.(variable).data(:,4)));
    nummonths = length(unique_month);
    f = figure('visible','off');
    thelineS = colormap;
    for imonth = 1:1:nummonths

        % Lets focus on that data alone
        table_month = donarMat.(variable).data(month_index==imonth,:);

        subplot(3,4,unique_month(imonth));
        plot_map('lonlat','color',[0.5,0.5,0.5]);   
        hold on;

        [unique_campaign,~,campaign_index] = unique(table_month(:,6));
        plot_xyColor(table_month(:,1),table_month(:,2),campaign_index,8);
        %upper(donarMat.(variable).deltares_name(1)),lower(strrep(donarMat.
        %(variable).deltares_name(2:end),'_',' ')),' '
        
        if imonth == 1 
            title([num2str(year(maxX)),': ',monthstr(unique_month(imonth),'mmm')],'FontWeight','bold','FontSize',thefontsize);
        else
            title(monthstr(unique_month(imonth),'mmm'),'FontWeight','bold','FontSize',thefontsize);
        end
        h2 = colorbar('south','fontsize',thefontsize);

        initpos = get(h2,'Position');
        set(gca,'FontSize',thefontsize);
        set(h2, ...
                   'Position',[initpos(1)+0.05, ...
                               initpos(2) - 0.01, ...
                               initpos(3)*0.7, ...
                               initpos(4)*0.2], 'fontsize',8);

        
    end
    fileName = ['themap','_',sensorname,'_',num2str(year(maxX))];
    print('-dpng',fileName);
    disp(['File: ',fileName,' -> Map. -- SAVED'])
    close(f);
    

    
    
    %%%%%%%%%%%%%%
    % HISTOGRAMS %
    %%%%%%%%%%%%%%
    f = figure('visible','off');      
    set(gcf,'position',[745   569   375   379])
    set(gcf,'PaperPositionMode','auto')
    hist(donarMat.(variable).data(:,5),100,'facecolor','k');

    elmax = max(donarMat.(variable).data(:,5));
    elmin = min(donarMat.(variable).data(:,5));
    numreg = length(donarMat.(variable).data(:,5));
    xlabel(['Bounds: [',num2str(elmin),',',num2str(elmax),']  -  Size: ',num2str(numreg)],'FontSize',thefontsize);
    title([strrep([upper(donarMat.(variable).deltares_name(1)),lower(donarMat.(variable).deltares_name(2:end))],'_',' '),' ',num2str(year(minX))],'FontWeight','bold','FontSize',thefontsize);
    set(gca,'FontSize',thefontsize);
    axis square
    fileName = ['thehist','_',sensorname,'_',num2str(year(minX))];
    print('-dpng',[fileName]);
    disp(['File: ',fileName,' -> Histogram. -- SAVED'])
    close(f);
end