function [cyclonetracks]=cyclonestats_compute_all(cyclone_files,setting)
disp('Start cyclonestats_compute_all')

% 0. Handling input
%ibtracsfile,dx,source,basinid,start_year,nyears,dir,lon_conv
nyears          = setting.nyears;
ibtracsfile     = cyclone_files.ibtracsfile;
dx              = setting.dx;
source          = setting.source;
start_year      = setting.start_year;
dir             = setting.destout;
lon_conv        = setting.lon_conv;
basinid         = setting.basinid;
dt              = setting.dt;    
seed            = setting.seed;

% set seed for whole file (later repeat in separate functions)
seedrng         = rng(seed,'twister');
seedrng         = rng(seed,'twister'); %do double to be sure
disp([' used Matlab seed by TCWiSE is: ',num2str(seedrng.Seed)])

% check nyears
if (nyears < 0)
    nyears=s.nryears;
end

% 1. Output definition
cyclonefile_observed    = cyclone_files.observed;       % historical tracks in new format (from IBTRACKS)

pdffile_obs             = cyclone_files.pdffile_obs;
mapsfile_obs            = cyclone_files.mapsfile_obs;

simfile                 = cyclone_files.simulated; 
pdffile_sim             = cyclone_files.pdffile_sim;
mapsfile_sim            = cyclone_files.mapsfile_sim;

ldbplotfile             = cyclone_files.ldbplotfile;
AoIfile                 = cyclone_files.AoIfile;
landfile                = setting.landfile;

% 2. Load SST
sst = load(cyclone_files.sstfile);
sst = sst.sst;

% 3. Convert IBTRACS data to proper format; will be skipped if you already have the cyclonefile_observed
if exist(cyclonefile_observed) ~= 2
    disp('Start computing cyclonestats_precompute_ibtracks_v04r00')    
    cyclonestats_precompute_ibtracks_v04r00(ibtracsfile,basinid,sst,cyclonefile_observed,'start_year',start_year,'end_year',setting.end_year, 'source',source,'lon_conversion',lon_conv);%,'seed',seedrng);
    s = load(cyclonefile_observed);
else
    s = load(cyclonefile_observed);
    disp('IBTRACS data already present')
end


% 4. Get grid based on tracks
dy          = dx;
xmin        = floor(nanmin(nanmin(s.lon)))-5;
xmax        = ceil(nanmax(nanmax(s.lon)))+5;
ymin        = floor(nanmin(nanmin(s.lat)))-5;
ymax        = ceil(nanmax(nanmax(s.lat)))+5;
[s.xg,s.yg] = meshgrid(xmin:dx:xmax,ymin:dy:ymax);
disp(' ');

% 5. Compute statistics of original data; will be skipped if you already have the pdffile
if exist(mapsfile_obs) ~= 2 || exist(pdffile_obs) ~= 2
    ss          = cyclonestats_compute_map_statistics(cyclonefile_observed,pdffile_obs,mapsfile_obs,s.xg,s.yg,'observed',dir,ldbplotfile, setting);
    disp(' done computing pdffile')    
    
else
    disp('Map_statistics already present - start loading')    
    ss          = load(pdffile_obs);
end
s.pgenesis  = ss.pgenesis;

% 6. Determine start and stop points for each cyclone based on cyclone genesis probability
disp(' ');
cyclones_per_year_in_basin      = size(s.vmax,1)/s.nryears;
[x0,y0,t0]                      = cyclonestats_cyclogenesis(cyclones_per_year_in_basin*cyclone_files.changefrequency,s.xg,s.yg,s.pgenesis,s.tgenesis,nyears);

% 7. Simulate tracks
if exist(simfile) ~= 2 
    
    % Main part
    disp(' ');
    tic
    ndays                       = 30;   % Maximum number of days for each simulated track
    [cyclonetracks,percbreak]   = cyclonestats_simulatetracks(x0,y0,t0,ndays,dt,ss, cyclone_files.sstfile, setting, 'latitude_allowed', setting.latitude_allowed, 'termination_method', setting.termination_method, 'landfile',landfile, 'landeffect', setting.additional_landeffect, 'coefficient_decay', setting.coefficientdecay, 'cutoff_sst', setting.cutoff_sst, 'cutoff_windspeed', setting.cutoff_windspeed);
    toc

    % Finish
    cyclonetracks.vmax          = cyclonetracks.vmax*cyclone_files.changeintensity;
    cyclonetracks.nryears       = nyears;
    cyclonetracks.percbreak     = percbreak;
    save(simfile,'-struct','cyclonetracks');
    disp('  done computing cyclonestats_simulatetracks')    
    
else
    disp('Cyclonetracks already present')    
    cyclonetracks = load(simfile);
end
    

% 8. Evaluate this: does genesis and termination overlap?
disp(' ' );
close all
Cliner = linspecer(6);
ldb=landboundary('read',ldbplotfile);
xldb=squeeze(ldb(:,1));
yldb=squeeze(ldb(:,2));

for jj = 1:2
    Y = 29.7/2;   X = 21.0;
    xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[X Y]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    if jj == 1
        
        hplot1 = plot(cyclonetracks.lon(:,1), cyclonetracks.lat(:,1), 'r.');
        hplot2 = plot(s.lon(:,1), s.lat(:,1), 'r.');
        
    else
        
        % Historical
        term1 = zeros(size(s.lon,1),2);
        for tt = 1:size(s.lon,1)
            idlastvmax  = find(~isnan(s.vmax(tt,:)));
            idlastvmax  = idlastvmax(end);
            term1(tt,1) = s.lon(tt,idlastvmax);
            term1(tt,2) = s.lat(tt,idlastvmax);
        end
        hplot2 = plot(term1(:,1), term1(:,2), 'r.');
        
        % Synthetic
        term2 = zeros(size(cyclonetracks.lon,1),2);
        for tt = 1:size(cyclonetracks.lon,1)
            idlastvmax = find(~isnan(cyclonetracks.vmax(tt,:)));
            idlastvmax = idlastvmax(end);
            term2(tt,1) = cyclonetracks.lon(tt,idlastvmax);
            term2(tt,2) = cyclonetracks.lat(tt,idlastvmax);
        end
        hplot1 = plot(term2(:,1), term2(:,2), 'r.');
    end
    plot(xldb,yldb,'k')
    set(hplot1, 'color', Cliner(1,:));
    set(hplot2, 'color', Cliner(2,:));
    legend([hplot2, hplot1], 'historical', 'synthetic')
    axis equal; box on; grid on;
    ylabel('latitude [°]')
    xlabel('longitude [°]')    
    xlim([min(min(s.xg)) max(max(s.xg))]);
    ylim([min(min(s.yg)) max(max(s.yg))]);
    if jj == 1; title('Genesis locations'); print([dir '\genesis_locs_both'],'-dpng'  ,'-r288'); end
    if jj == 2; title('Termination locations'); print([dir '\term_locs_both'],'-dpng'  ,'-r288'); end
    close all
end

% 9. Maps of cyclone tracks of historic and simulated
plot_alpha = 0;
for jj = 1:2
    
    % First determine facealpha    
    Y = 29.7/2;   X = 21.0;
    xSize = X - 2*0.5;   ySize = Y - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); 
    hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[X Y]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    
    if plot_alpha == 1
        alpha_historic = 0.75;
        if jj == 1
            for kk=1:size(s.lon,1)
                p1 = plot(s.lon(kk,:), s.lat(kk,:), '-k');
                p1.Color(4) = alpha_historic;
            end
        else
            for kk=1:size(cyclonetracks.lon,1)
                id = ~isnan(cyclonetracks.lat(kk,:));
                p1 = plot(cyclonetracks.lon(kk,id), cyclonetracks.lat(kk,id), '-k');
                factor_wanted = size(s.lon,1)/size(cyclonetracks.lon,1)*alpha_historic;   
                if factor_wanted > 1
                    factor_wanted = 1;
                end
                p1.Color(4) = factor_wanted;
            end
        end
        
    else
        if jj == 1
            for kk=1:size(s.lon,1)
                p1 = plot(s.lon(kk,:), s.lat(kk,:));
            end
        else
            for kk=1:size(cyclonetracks.lon,1)
                id = ~isnan(cyclonetracks.lat(kk,:));
                p1 = plot(cyclonetracks.lon(kk,id), cyclonetracks.lat(kk,id));
            end
        end
    end
    
    plot(xldb,yldb,'k', 'linewidth',1)
    axis equal; box on; grid on;
    ylabel('latitude [°]')
    xlabel('longitude [°]')    
    xlim([min(min(s.xg)) max(max(s.xg))]);
    ylim([min(min(s.yg)) max(max(s.yg))]);
    if jj == 1; title('Historical tracks'); print([dir '\tracks_historic'],'-dpng'  ,'-r288'); end
    if jj == 2; title('Synthetic tracks'); print([dir '\tracks_synthetic'],'-dpng'  ,'-r288'); end
    close all
end

% 10. PDF maps of synthetic
ss          = cyclonestats_compute_map_statistics(simfile,pdffile_sim,mapsfile_sim,s.xg,s.yg,'simulated',dir,ldbplotfile, setting);
disp('Finished cyclonstats_compute_all')
disp(' ');


