function cyclonestats_comparison(cyclone_files, dir)
disp('Start cyclonestats_comparison.m')

% Simple plotting function that makes sure that things look the same
% Load the data -> this can take a while since the files are large
cd(dir)
data1 = load(cyclone_files.pdffile_obs);
data2 = load(cyclone_files.mapsfile_obs);
data3 = load(cyclone_files.pdffile_sim);
data4 = load(cyclone_files.mapsfile_sim);
data5 = load(cyclone_files.sstfile);

% Determine legends
legends.pgenesis                = [0 round(nanmax(data3.pgenesis(:))*1000)/1000];
legends.ptermination            = [0 round(nanmax(data3.ptermination(:))*1000)/1000];

val                             = data2.parameters(1).parameter.val;
val                             = val(~isnan(val));     val = sort(val);
legends.returnperiod            = [0 round(nanmax(1./val)*100)/100];

val                             = data2.parameters(2).parameter.val;
val                             = val(~isnan(val));     val = sort(val);
legends.returnperiod_50         = [0 round(nanmax(1./val)*100)/100];

val                             = data2.parameters(3).parameter.val;
val                             = val(~isnan(val));     val = sort(val);
legends.returnperiod_100        = [0 round(nanmax(1./val)*100)/100];

val                             = data2.parameters(4).parameter.val;
val                             = val(~isnan(val));     val = sort(val);
legends.vmax_mean               = [0 val(ceil(length(val)*0.95))];

val                             = data2.parameters(5).parameter.val;
val                             = val(~isnan(val));     val = sort(val);
legends.vmax_std                = [0 val(ceil(length(val)*0.95))];

% Colormap and landboundaries
cmp = colormap_whitejet();
ldb=landboundary('read',cyclone_files.ldbplotfile);
xldb=squeeze(ldb(:,1));
yldb=squeeze(ldb(:,2));

% Make plots of genesis and termination
for jj = 1:2
    if jj == 1; var = 'pgenesis';       legendsname = 'probability of TC genesis [-]'; end
    if jj == 2; var = 'ptermination';   legendsname = 'probability of TC terminination [-]'; end
    for ii = 1:2
        close all
        Y = 29.7/2;   X = 21.0;
        xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
        hFig = figure('visible','off'); hold on;
        set(hFig, 'PaperUnits','centimeters');
        set(hFig, 'PaperSize',[X Y]);
        set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
        set(hFig, 'PaperOrientation','portrait');
        if ii == 1
            tmpdatavarplot = data1.(var); tmpdatavarplot(data1.(var)==0)=NaN;
            pcolor(data1.xg, data1.yg, tmpdatavarplot); shading flat;
        end
        if ii == 2
            tmpdatavarplot = data3.(var); tmpdatavarplot(data3.(var)==0)=NaN;
            pcolor(data3.xg, data3.yg, tmpdatavarplot); shading flat;
        end
        colormap(cmp); plot(xldb, yldb, 'k');
        
        % The Kirchhofer score of similarity (S) and correlation (R)           
        if ii == 1
            eof1org = data1.(var); tmpdatavarplot(data1.(var)==0)=NaN;
            eof1lift = data3.(var); tmpdatavarplot(data3.(var)==0)=NaN;
            [S, R ] = similarity_score_nan(eof1org, eof1lift);
            
            htext = ['R: ', num2str(R, '% 10.2f'),' [-]' ];
                        
            htext = text(0.03, 0.92, htext, 'sc','Color','k', 'Fontsize',10); 
        end
        
        grid on; box on;
        axis equal;
        ylabel('latitude [°]')
        xlabel('longitude [°]')
        caxis([legends.(var)]);
        xlim([nanmin(nanmin(data1.xg)) nanmax(nanmax(data1.xg))]);
        ylim([nanmin(nanmin(data1.yg)) nanmax(nanmax(data1.yg))]);
        hlegends = colorbar; ylabel(hlegends, legendsname)
        if ii == 1; title('Historical'); end
        if ii == 2; title('Synthetic'); end
        cd(dir);
        mkdir('comparison'); cd('comparison');
        print([var, num2str(ii)],'-dpng'  ,'-r500');
    end
end

% Make plots of return values
cmp = colormap_whitejet();

for jj = 1:5
    if jj == 1; var = 'returnperiod';       legendsname = 'yearly probability of a TC [-]'; end
    if jj == 2; var = 'returnperiod_50';    legendsname = 'yearly probability of a TC  with a wind speed of > 50 knots [-]';  end
    if jj == 3; var = 'returnperiod_100';   legendsname = 'yearly probability of a TC  with a wind speed of > 100 knots [-]';  end
    if jj == 4; var = 'vmax_mean';          legendsname = 'mean maximum sustained wind speed [knots]';  end
    if jj == 5; var = 'vmax_std';           legendsname = 'standard deviation of maximum sustained wind speed [knots]';  end
    
    for ii = 1:2
        close all
        Y = 29.7/2;   X = 21.0;
        xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
        hFig = figure('visible','off');
        hold on;
        set(hFig, 'PaperUnits','centimeters');
        set(hFig, 'PaperSize',[X Y]);
        set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
        set(hFig, 'PaperOrientation','portrait');
        
        if ii == 1; datanow   = data2.parameters(jj).parameter; end
        if ii == 2; datanow   = data4.parameters(jj).parameter; end
        if jj > 3
            h = pcolor(datanow.x, datanow.y, datanow.val);
        else
            h = pcolor(datanow.x, datanow.y, 1./datanow.val);
        end
        colormap(cmp); plot(xldb, yldb, 'k');
        set(h, 'EdgeColor', 'none');
        
        % The Kirchhofer score of similarity (S) and correlation (R)           
        if ii == 1
            eof1org = data2.parameters(jj).parameter.val;
            eof1lift = data4.parameters(jj).parameter.val;
            [S, R ] = similarity_score_nan(eof1org, eof1lift);
            htext = ['R: ', num2str(R, '% 10.2f'),' [-]' ];
            htext = text(0.03, 0.92, htext, 'sc','Color','k', 'Fontsize',10); 
        end        
        
        grid on; box on;
        axis equal;
        ylabel('latitude [°]')
        xlabel('longitude [°]')
        caxis([legends.(var)]);
        xlim([nanmin(nanmin(data1.xg)) nanmax(nanmax(data1.xg))]);
        ylim([nanmin(nanmin(data1.yg)) nanmax(nanmax(data1.yg))]);
        hlegends = colorbar; ylabel(hlegends, legendsname)
        if ii == 1; title('Historical'); end
        if ii == 2; title('Synthetic'); end
        cd(dir);
        mkdir('comparison'); cd('comparison');
        print([var, '_', num2str(ii)],'-dpng'  ,'-r288');
    end
end

% Quiver
datanow1   = data2.parameters(end).parameter;
datanow2   = data4.parameters(end).parameter;
factor     = 10;
close all
Y = 29.7/2;   X = 21.0;
xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off'); hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[X Y]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');
hquiver1 = quiver(datanow1.x, datanow1.y, datanow1.u*factor, datanow1.v*factor, 'b');
hquiver2 = quiver(datanow2.x, datanow2.y, datanow2.u*factor, datanow2.v*factor, 'r');
plot(xldb, yldb, 'k');
legend('historical', 'simulated');
grid on; box on;
axis equal;
caxis([legends.(var)]);
xlim([nanmin(nanmin(data1.xg)) nanmax(nanmax(data1.xg))]);
ylim([nanmin(nanmin(data1.yg)) nanmax(nanmax(data1.yg))]);
print('quiver','-dpng'  ,'-r288');

% Occurance
close all
for ii = 1:2
    var = 'occurance';       legendsname = 'amount of TCs yearly [-]'; 
    if ii == 1; datawanted = 1./(data2.parameters(1).parameter.val); end
    if ii == 2; datawanted = 1./(data4.parameters(1).parameter.val); end

    close all
    Y = 29.7/2;   X = 21.0;
    xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off');
    hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[X Y]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
	h = pcolor(data2.parameters(1).parameter.x, data2.parameters(1).parameter.y, datawanted);
    colormap(cmp); plot(xldb, yldb, 'k');
    set(h, 'EdgeColor', 'none');
    grid on; box on;
    axis equal;
    ylabel('latitude [°]')
    xlabel('longitude [°]')
    xlim([nanmin(nanmin(data2.parameters(1).parameter.x)) nanmax(nanmax(data2.parameters(1).parameter.x))]);
    ylim([nanmin(nanmin(data2.parameters(1).parameter.y)) nanmax(nanmax(data2.parameters(1).parameter.y))]);
    hlegends = colorbar; ylabel(hlegends, legendsname)
    if ii == 1; title('Historical'); end
    if ii == 2; title('Synthetic'); end
    cd(dir);
    mkdir('comparison'); cd('comparison');
    clim([0 0.5]);
    print([var, '_', num2str(ii)],'-dpng'  ,'-r288');
end
    

%% Observations points
% If non-defined, we do random 3x3 points
if isempty(cyclone_files.comparison_points)
    steps_x = round(1:size(data1.xg,1)/5:size(data1.xg,1));
    steps_y = round(1:size(data1.xg,2)/5:size(data1.yg,2));
    count_step = 0;
    for ii = 1:length(steps_x)-2
        for jj = 1:length(steps_y)-2
            count_step = count_step+1;
            cyclone_files.comparison_points(count_step,1) = data1.xg(steps_x(ii+1), steps_y(jj+1));
            cyclone_files.comparison_points(count_step,2) = data1.yg(steps_x(ii+1), steps_y(jj+1));
        end
    end
end

% Re-do part of the determination
synthetic   = load(cyclone_files.simulated);
synthetic 	= cyclonestats_compute_foreward_speed_components(synthetic);

observed    = load(cyclone_files.observed);
observed 	= cyclonestats_compute_foreward_speed_components(observed);
duration    = [observed.nryears synthetic.nryears];

for ii = 1:size(cyclone_files.comparison_points,1)

    % BE AWARE, IN ROW ANALYSIS WIND SPEEDS ARE CONVERTED FROM KNOTS TO M/S. TCWISE IS COMPUTED IN KNOTS
	
    % Compute distances to synthetic points
    [distances_synthetic, azi1, azi2, S12, m12, M12, M21, a12]  = geoddistance(synthetic.lat, synthetic.lon, cyclone_files.comparison_points(ii,2), cyclone_files.comparison_points(ii,1));
    [distances_observed, azi1, azi2, S12, m12, M12, M21, a12]   = geoddistance(observed.lat, observed.lon, cyclone_files.comparison_points(ii,2), cyclone_files.comparison_points(ii,1));
    	
    % observed wanted
    distances_wanted    = 200*10^3;    % within 200 km
    idfind_observed     = (distances_observed<distances_wanted);
    [s_observed(ii)]    = cyclonestats_rowanalysis(observed,idfind_observed);

    % synthetic wanted
    idfind_synthetic    = find(distances_synthetic<distances_wanted);
    [s_synthetic(ii)]   = cyclonestats_rowanalysis(synthetic,idfind_synthetic);
    
end

% nr of subplots
nrcols = 3;
nr_subplots = ceil(size(cyclone_files.comparison_points,1)/nrcols); % for now always 3 colums and 'nr_subplots' rows

% Figures
cd(dir);
mkdir('comparison'); cd('comparison');

save('s_observed.mat', 's_observed')
save('s_synthetic.mat', 's_synthetic')

Cliner = linspecer(6);
for types = 1:3
    
    close all
    A4fig
    clear meanvalue
    if types == 1; varwanted = 'forward';           xlimwanted = [0 15];    unit = ' [m/s]';        namewanted = 'c'; end
    if types == 2; varwanted = 'vmax';              xlimwanted = [0 80];    unit = ' [m/s]';        namewanted = 'v_{max}'; end
    if types == 3; varwanted = 'heading';           xlimwanted = [0 2*pi];  unit = ' [\circ]';    namewanted = '\theta'; end
    clear historical synthetic 
    for ii = 1:size(cyclone_files.comparison_points,1)
        
        % Find
        historical.occurences    = s_observed(ii).(varwanted);
        synthetic.occurences     = s_synthetic(ii).(varwanted);
        
        if types == 3; historical.occurences = deg2rad(historical.occurences); end
        if types == 3; synthetic.occurences = deg2rad(synthetic.occurences); end

        subplot(nr_subplots,nrcols,ii); hold  on;
        [error] = goodness_of_fit(historical.occurences, synthetic.occurences);
        medianvalue(ii,1)        = nanmedian( historical.occurences );
        medianvalue(ii,2)        = nanmedian( synthetic.occurences );

        hplot1a = cdfplot1(historical.occurences);      %hplot1b = plot([medianvalue(ii,1) medianvalue(ii,1)], [0 1], '--');
        hplot2a = cdfplot1(synthetic.occurences);       %hplot2b = plot([medianvalue(ii,2) medianvalue(ii,2)], [0 1], '--');
        
        TMP     = sort(historical.occurences); 
        rangewanted = [0.05 0.95];
        hplot3a = cdfplot1(TMP(1: round(rangewanted(end)*length(TMP)))); set(hplot3a, 'linestyle', '--', 'color', Cliner(3,:), 'linewidth', 1);
        hplot3b = cdfplot1(TMP(round(rangewanted(1)*length(TMP)):end)); set(hplot3b, 'linestyle', '--', 'color', Cliner(3,:), 'linewidth',1);

        set(hplot1a, 'color', Cliner(1,:));             
        set(hplot2a, 'color', Cliner(2,:));           
        xlim([xlimwanted]);
        
        htext1  = ['nMAE  ' num2str(error(6).value, '% 10.2f'), ' [-]'];        htext = text(0.55, 0.30, htext1, 'sc', 'Fontsize', 7);
        htext2  = ['RMSE ' num2str(error(3).value, '% 10.1f') unit];            htext = text(0.55, 0.20, htext2, 'sc', 'Fontsize', 7);
        htext3  = ['bias ' num2str(error(10).value, '% 10.1f') unit];           htext = text(0.55, 0.10, htext3, 'sc', 'Fontsize', 7);
        grid on; box on; 
        
%         [h(1), p(1), stats1]     = ansaribradley(t(idwanted),x(idwanted));   % or H=1  if the null hypothesis can be rejected at the 5% level
%         [h(2), p(2), stat2]      = kstest2(t(idwanted),x(idwanted));         % reject the null hypothesis at the 5% significance level.
%         [p(3), h(3), stats3]     = ranksum(t(idwanted),x(idwanted));
%         htext4  = ['p_{AB}  ' num2str(error(11).value(1), '% 10.2f'), ' [-]'];        htext = text(0.55, 0.40, htext4, 'sc', 'Fontsize', 7);
%         htext5  = ['p_{KS} ' num2str(error(11).value(1), '% 10.2f') '[-]'];           htext = text(0.55, 0.50, htext5, 'sc', 'Fontsize', 7);
%         htext6  = ['p_{RS} ' num2str(error(11).value(1), '% 10.2f') '[-]'];           htext = text(0.55, 0.60, htext6, 'sc', 'Fontsize', 7);
%         grid on; box on; 
        
        if ii == 1 || ii == 4 || ii == 7; ylabel('CDF [-]');  end
        if ii == 7 || ii == 8 || ii == 9; xlabel([namewanted, unit]); end
        box on; title(['Location ', num2str(ii)])
        if ii == 1; hlegend = legend([hplot1a hplot3b hplot2a], 'historical', '90% confidence historical ','synthetic'); end
        errorsave(ii).error = error;
        
    end
    set(hlegend, 'position', [0.2 0.01 0.6 0.02], 'orientation','horizontal');
    fname = [varwanted, '.png'];
    print(fname,'-dpng'  ,'-r288');
    close all
    
    % Write errors
    try
        clear writing
        for x1 = 1:length(errorsave)
            writing{x1+1,1} = ['Location ' num2str(x1)];
            for x2 = 1:length(errorsave(x1).error)
                writing{x1+1,x2+1} = errorsave(x1).error(x2).value;
                writing{1,x2+1}    = errorsave(x1).error(x2).name;
            end
        end
        xlswrite([varwanted, '.xls'],writing);
%         clear errorsave
    catch
    end
    save([varwanted, '.mat'],'errorsave'); %TL: dit ging fout bij Tonga_Samoa - errorsave variable not found....
    clear errorsave

    % Map with location
    Y = 29.7/2;   X = 21.0;
    xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off');
    hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[X Y]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    for ii = 1:size(cyclone_files.comparison_points,1)
        scatter(cyclone_files.comparison_points(ii,1), cyclone_files.comparison_points(ii,2), [], medianvalue(ii,1), 'filled');
        scatter(cyclone_files.comparison_points(ii,1)+0.5, cyclone_files.comparison_points(ii,2), [], medianvalue(ii,2), 'filled');
        htext = text(cyclone_files.comparison_points(ii,1)+0.25, cyclone_files.comparison_points(ii,2)+0.5, ['Location ', num2str(ii)]);
    end
    plot(xldb, yldb, 'k');
    grid on; box on;
    axis equal;
    hlegends = colorbar; ylabel(hlegends, varwanted)
    xlim([nanmin(cyclone_files.comparison_points(:,1))-5 nanmax(cyclone_files.comparison_points(:,1))+5]);
    ylim([nanmin(cyclone_files.comparison_points(:,2))-5 nanmax(cyclone_files.comparison_points(:,2))+5]);
    fname = [varwanted, '_map.png'];
    print(fname,'-dpng'  ,'-r288');
    
    
    % PDFs
    close all
    A4fig
    clear meanvalue
    if types == 1; varwanted = 'forward';           xlimwanted = [0 15];    unit = ' [m/s]'; end
    if types == 2; varwanted = 'vmax';              xlimwanted = [0 160];   unit = ' [m/s]'; end
    if types == 3; varwanted = 'heading';           xlimwanted = [0 360];  unit = ' [degrees]'; end
    clear historical synthetic 
    for ii = 1:size(cyclone_files.comparison_points,1)
        
        % Find
        historical.occurences    = s_observed(ii).(varwanted);
        synthetic.occurences     = s_synthetic(ii).(varwanted);
        
        subplot(3,3,ii); hold  on;
        f1 = kde(historical.occurences);
        f2 = kde(synthetic.occurences);
        hplot1 = plot(f1.x{:}, f1.f, 'linewidth', 2, 'color', Cliner(1,:));
        hplot2 = plot(f2.x{:}, f2.f, 'linewidth', 2, 'color', Cliner(2,:));
        xlim([xlimwanted]);
        
        %[error] = goodness_of_fit(historical.occurences, synthetic.occurences);
        %htext1  = ['RMSE ' num2str(error(3).value, '% 10.3f') unit];      htext = text(0.5, 0.20, htext1, 'sc', 'Fontsize', 5);
        %htext2  = ['MAE  ' num2str(error(5).value, '% 10.3f') unit];      htext = text(0.5, 0.15, htext2, 'sc', 'Fontsize', 5);
        %htext3  = ['K    ' num2str(0.05, '% 10.3f')];                     htext = text(0.5, 0.10, htext3, 'sc', 'Fontsize', 5);
        grid on; box on; 
        
        if ii == 1 || ii == 4 || ii == 7; ylabel('PDF [-]');  end
        if types == 1 || types == 2 
            if ii == 7 || ii == 8 || ii == 9; xlabel([varwanted, unit]); end
        end
        if types == 3
            set(gca, 'xtick', [0 90 180 270 360], 'xticklabel', {'S', 'E', 'N', 'W', 'S'}); 
        end
        box on; title(['Location ', num2str(ii)])
        if ii == 1; hlegend = legend([hplot1 hplot2], 'historical', 'synthetic'); end
    end
    fname = [varwanted, '_PDF.png'];
    print(fname,'-dpng'  ,'-r288');
    close all
end

%% Done
disp('Finish cyclonestats_comparison.m')

end

