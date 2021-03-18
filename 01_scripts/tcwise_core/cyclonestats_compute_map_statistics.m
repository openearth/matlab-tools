function [s1]=cyclonestats_compute_map_statistics(inputfile,pdffile,mapsfile,xg,yg,opt,dir,ldbplotfile,setting)
disp('Start cyclonestats_compute_map_statistics')

%% Initialisation KDE ranges
% Location
min_number_of_points        = setting.window_KDE;           	% Find at least this number of occurences within one bin (not yet splitted up in vectors or bins)
min_number_of_points_KDE    = 3;                                % at least # points to describe a KDE otherwise we leave it empty
lon_search_range            = setting.window_dx;            	% Maximum longitudinal search range in degrees (so 10 degrees = +/- 1000 km)
lat_search_range            = setting.window_dx;            	% Maximum latitudinal search range in degrees
kde_options                 = kdeoptset('inc', 100);
reduce_size                 = 1;

% Load in track input file
s 	= load(inputfile);
s 	= cyclonestats_compute_foreward_speed_components(s);
    
% Determine time span of dataset
s1.nryears=s.nryears;
s1.nrcyclones=size(s.lon,1);
dx=xg(1,2)-xg(1,1);
dy=yg(2,1)-yg(1,1);
lat_search_range=max(lat_search_range,dy);
s1.xg=xg;
s1.yg=yg;

% Auto or predefined
if setting.kde.auto 
    
    % Check settings
    u0=s.u0;
    v0=s.v0;
    u1=s.u1;
    v1=s.v1;

    % Get rid of NaNs
    u0(isnan(u1))=NaN;
    v0(isnan(v1))=NaN;
    u1(isnan(u0))=NaN;
    v1(isnan(v0))=NaN;

    u0=u0(~isnan(u0));
    v0=v0(~isnan(v0));
    u1=u1(~isnan(u1));
    v1=v1(~isnan(v1));

    spd0=sqrt(u0.^2+v0.^2);
    phi0=atan2(v0,u0);
    phi0=mod(phi0,2*pi);

    spd1=sqrt(u1.^2+v1.^2);
    phi1=atan2(v1,u1);
    phi1=mod(phi1,2*pi);

    dspd=spd1-spd0;
    dphi=phi1-phi0;
    dphi=dphi;
    idnegative = dphi<pi*-1;
    idpostive  = dphi>pi;
    dphi(idnegative)    = dphi(idnegative)+2*pi;
    dphi(idpostive)     = dphi(idpostive)-2*pi;

    forward_speed=spd0;
    forward_speed_change=dspd;

    % Foreward direction
    heading=phi0;
    heading_change=dphi;

    % Vmax
    vmax0=s.vmax0;
    vmax1=s.vmax1;
    vmax2=s.vmax2;
    vmax0=vmax0(~isnan(vmax0));
    vmax1=vmax1(~isnan(vmax1));
    vmax2=vmax2(~isnan(vmax2));

    vmax=vmax1;
    vmax_change=vmax2-vmax1;
    dvmax0=vmax1-vmax0;

    % Forward speed
    clear forward_speed_step vmax_step heading_step
    steps = setting.kde.auto_steps;
    forward_speed_sort  = sort(forward_speed);
    vmax_sort           = sort(vmax0);
    heading_sort        = sort(heading);
    for ss = 1:length(steps)
        if steps(ss) == 0
            forward_speed_step(ss)  = forward_speed_sort(1);
            vmax_step(ss)           = vmax_sort(1);
            heading_step(ss)        = heading_sort(1);
        elseif steps(ss) == 1
            forward_speed_step(ss)  = forward_speed_sort(end);
            vmax_step(ss)           = vmax_sort(end);
            heading_step(ss)        = heading_sort(end);
        else
            forward_speed_step(ss)  = forward_speed_sort(round(steps(ss)*length(forward_speed_sort)));
            vmax_step(ss)           = vmax_sort(round(steps(ss)*length(forward_speed_sort)));
            heading_step(ss)        = heading_sort(round(steps(ss)*length(forward_speed_sort)));
        end
    end

    % Show heading
    disp([' determine the ranges automatically!'])
    disp(['  forward: we are running with: ', num2str(median(diff(forward_speed_step))), ' m/s'])
    disp(['  heading: we are running with: ', num2str(median(diff(heading_step))), ' rad'])
    disp(['  vmax: we are running with: ', num2str(median(diff(vmax_step))) , ' knots'])
    disp(['  '])

    % Fully replace with found distribution
    forward_speed_bins      = forward_speed_step;
    heading_bins            = heading_step;
    vmax_bins               = vmax_step;
else
    
    % Speeds
    disp([' using user-defined KDE ranges']);
    forward_speed_bins          = setting.kde.forward_speed_bins;           % bins
    forward_search_range        = setting.kde.forward_search_range;         % search areas = 4 knots

    % Heading
    heading_bins                = setting.kde.heading_bins;                 % bins
    heading_search_range        = setting.kde.heading_search_range;            

    % Vmax
    vmax_bins                   = setting.kde.vmax_bins;
    vmax_search_range           = setting.kde.vmax_search_range;

end




% Statistics of historical events
if strcmpi(opt,'observed')
    
    % Determine genesis and termination probability on grid
    disp(' determine cyclogenesis & termination likelyhood ...');
    
    % Determine genesis probability and statistics
    [pgenesis,vmax_avg_genesis,gen_occ  ]	= cyclonestats_compute_genesis_probability(s,xg,yg,setting.window_genesis_term);
    s1.pgenesis=pgenesis;                   % Genesis Probability on spatial grid
    s1.vmax_avg_genesis=vmax_avg_genesis;   % Avg vmax at each gen location
    s1.gen_occ=gen_occ;                     % Structure with historical occurrences at genesis for each location
    
    % Determine termination probability and statistics
    [ptermination,vmax_avg_termination] 	= cyclonestats_compute_termination_probability(s,xg,yg,setting.window_genesis_term);
    s1.ptermination=ptermination;                   % Termination Probability on spatial grid
    s1.vmax_avg_termination=vmax_avg_termination;   % Avg vmax at each termination location
    
    % Compute termination probability at each grid cell as a function of duration and intensity
    termination=cyclonestats_compute_termination_PDF(inputfile,xg,yg);
    
    % Plot all 8 termination PDFs
    pdf_Term_plots(termination,dir,ldbplotfile,xg,yg);
    s1.termination=termination;
    
    % Colormap
    cmp = jet;
    ldb=landboundary('read',ldbplotfile);
    xldb=squeeze(ldb(:,1));
    yldb=squeeze(ldb(:,2));
    
    % Plot genesis density
    Yfig = 29.7/2;   XFig = 21.0;
    xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[XFig Yfig]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    axis equal
    xlim([min(min(xg)) max(max(xg))]);
    ylim([min(min(yg)) max(max(yg))]);
    pgenesisplot = pgenesis; pgenesisplot(pgenesis==0)=NaN;
    pcolor(xg,yg,pgenesisplot);shading flat;colorbar;colormap(cmp);title('Historic Genesis density')
    plot(xldb,yldb,'k')
    ylabel('latitude [°]')
    xlabel('longitude [°]')
    grid on; box on;
    print([dir '\genesis_PDF_historic'],'-dpng'  ,'-r288');
    
    % Plot overal termination density
    Yfig = 29.7/2;   XFig = 21.0;
    xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[XFig Yfig]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    pterminationplot = ptermination; pterminationplot(ptermination==0)=NaN;
    pcolor(xg,yg,pterminationplot);shading flat;colorbar;colormap(cmp);title('Historic Termination density')
    axis equal;
    xlim([min(min(xg)) max(max(xg))]);
    ylim([min(min(yg)) max(max(yg))]);
    plot(xldb,yldb,'k')
    ylabel('latitude [°]')
    xlabel('longitude [°]')
    grid on; box on;
    print([dir '\term_PDF_historic'],'-dpng'  ,'-r288');
    
    % Statistics of simulated events
elseif strcmpi(opt,'simulated')
    
    % Colormap
    cmp = jet;
    ldb=landboundary('read',ldbplotfile);
    xldb=squeeze(ldb(:,1));
    yldb=squeeze(ldb(:,2));
    
    % No termination PDFs required per condition
    disp(' determine cyclogenesis & termination likelyhood ...');
    [pgenesis,vmax_avg_genesis]=cyclonestats_compute_genesis_probability(s,xg,yg,setting.window_genesis_term);
    s1.pgenesis=pgenesis;
    s1.vmax_avg_genesis=vmax_avg_genesis;
    [ptermination,vmax_avg_termination]=cyclonestats_compute_termination_probability(s,xg,yg,setting.window_genesis_term);
    s1.ptermination=ptermination;
    s1.vmax_avg_termination=vmax_avg_termination;
    
    Yfig = 29.7/2;   XFig = 21.0;
    xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[XFig Yfig]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    pgenesisplot = pgenesis; pgenesisplot(pgenesis==0)=NaN;
    pcolor(xg,yg,pgenesisplot);shading flat;colorbar;colormap(cmp);title('Simulated Genesis density')
    
    axis equal; grid on; box on;
    xlim([min(min(xg)) max(max(xg))]);
    ylim([min(min(yg)) max(max(yg))]);
    plot(xldb,yldb,'k')
    print([dir '\genesis_PDF_simulated'],'-dpng'  ,'-r288');
    
    Yfig = 29.7/2;   XFig = 21.0;
    xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[XFig Yfig]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    pterminationplot = ptermination; pterminationplot(ptermination==0)=NaN;
    pcolor(xg,yg,pterminationplot);shading flat;colorbar;colormap(cmp);title('Simulated Termination density')
    axis equal; grid on; box on;
    xlim([min(min(xg)) max(max(xg))]);
    ylim([min(min(yg)) max(max(yg))]);
    plot(xldb,yldb,'k')
    ylabel('latitude [°]')
    xlabel('longitude [°]')
    print([dir '\term_PDF_simulated'],'-dpng'  ,'-r288');
    
end

% Delete data that is on land
% use landfile map (same as for tracks)
% we basically are deleting those points
if ~isempty(setting.landfile) & setting.exclude_land_map_KDE == 1 & strcmpi(opt,'observed')
    
    % Get x,y,z
    disp(' removing land points (this may take a while)');
    data                = load(setting.landfile);
    Ftopo               = scatteredInterpolant(data(:,1), data(:,2), data(:,3), 'natural', 'none');
    
    % Is x0 and y0 in this domain?
    resolution          = 0.1;          % 1 degree = 100km ; 0.1 = 10 km
    x0TMP               = nanmin(xg(:)):resolution:nanmax(xg(:));
    y0TMP               = nanmin(yg(:)):resolution:nanmax(yg(:));
    
    % Mesh grid
    [x0_mesh, y0_mesh]  = meshgrid(x0TMP,y0TMP);
    z0_mesh             = Ftopo(x0_mesh, y0_mesh);
    onland              = z0_mesh > 0;
    
    % Delete certain points
    tic
    for i1 = 1:size(s.lon,1)
        for i2 = 1:size(s.lon,2)
            if ~isnan(s.lon(i1,i2))
                [index, distance, twoout]= nearxy(x0_mesh, y0_mesh, s.lon(i1,i2), s.lat(i1,i2), 0.01);    % point within 10 km of land = non
                onland_list              = onland(index);
                if sum(onland_list)>0
                    if setting.methodlandv_KDE == 1
                        s.lon(i1,i2)    = NaN;
                        s.lat(i1,i2)    = NaN;
                        s.vmax(i1,i2)   = NaN;
                    elseif setting.methodlandv_KDE == 2
                        s.vmax2(i1,i2)  = s.vmax1(i1,i2);       % means there will be zero gradient
                    end
                end
            end
        end
    end
    toc
end


%% Determine track statistics
disp(' determine track statistics ...');

% Option 1 is per grid point
% Option 2 is for entire latitude
maxnrpoints     = zeros(size(xg,1),size(xg,2));
s1.enoughdata   = zeros(size(xg,1),size(xg,2));
maxdist         = maxnrpoints;

for option=1:2
    
    if option==1
        sz1=size(xg,1);
        sz2=size(xg,2);
        par='location';
        n=0;
        disp(['    starting on PDFs for location'])
    else
        sz1=size(xg,1);
        sz2=1;
        par='latitude';
        n = 0;
        disp(['    starting on PDFs for latitude'])
    end
    
    % Loop through grid points
    for ii=1:sz1 % y direction
        
        if option==1
            disp(['     ', num2str(100*n/(size(xg,1)*size(xg,2)),'%0.1f') ' % complete on location']);
        else
            disp(['     ', num2str(100*n/(sz1),'%0.1f') ' % complete on latitude']);
        end
        
        for jj=1:sz2 % x direction
            n=n+1;
            
            if option==1
                
                % Find data in box
                xmin=xg(ii,jj)-0.5*dx;
                xmax=xg(ii,jj)+0.5*dx;
                ymin=yg(ii,jj)-0.5*dy;
                ymax=yg(ii,jj)+0.5*dy;
                ninrange=0;
                nrtries=0;
                xx=1;
                yy=0;
                % Continue until enough data points found or max search
                % range is reached. alternate in expanding in x and y
                % direction and each time check if enough data is found
                
                while ninrange<min_number_of_points
                    nrtries=nrtries+1;
                    inrange=s.lon>=xmin & s.lon<=xmax & s.lat>=ymin & s.lat<=ymax;
                    ninrange=sum(sum(inrange));
                    
                    if ninrange<min_number_of_points
                        if xx
                            xmin=xmin-0.5*dx;
                            xmax=xmax+0.5*dx;
                            xx=0;
                            yy=1;
                        else
                            if ymax-ymin<lat_search_range
                                if yy
                                    ymin=ymin-0.5*dy;
                                    ymax=ymax+0.5*dy;
                                    yy=0;
                                    xx=1;
                                end
                            else
                                xx=1;
                            end
                        end
                    end
                    if xmax-xmin>lon_search_range
                        s1.enoughdata(ii,jj) = 0;
                        break
                    end
                end
                maxnrpoints(ii,jj)  = ninrange; % Nr of data points inrange
                maxdist(ii,jj)      = xmax-xmin;    % X search range for grid cell
                
                % Save information on the size
                s1.location(ii,jj).information_box  = [xmin xmax; ymin ymax];
                s1.location(ii,jj).ninrange         = ninrange;
                
                % Prevent distances>circumference of earth
                % Prevent distances>circumference of earth
                ddegx=s.lon-xg(ii,jj);
                if any(ddegx(:)>180)
                    ddegx(ddegx>180)=ddegx(ddegx>180)-360;
                end
                if any(ddegx(:)<-180)
                    ddegx(ddegx<-180)=ddegx(ddegx<-180)+360;
                end
                ddegy=s.lat-yg(ii,jj);
                if any(ddegy(:)>180)
                    ddegy(ddegy>180)=ddegy(ddegy>180)-360;
                end
                if any(ddegy(:)<-180)
                    ddegy(ddegy<-180)=ddegy(ddegy<-180)+360;
                end
                distances=sqrt((111.0*cos(yg(ii,jj)*pi/180)*ddegx).^2 + (111.0*ddegy).^2);
                
                % Check if nothing is going wrong
                if max(distances(:))>45000/2
                    disp('Warning: Distance larger than half the circumference of Earth')
                end
                
                % Compute return period of storm passing by within 100 km
                inrange100=distances<=100;
                
                % Return period of all storms
                inrange100=sum(inrange100,2);
                inrange100=min(inrange100,1);
                inrange100=sum(inrange100);
                if inrange100>0
                    s1.return_period(ii,jj)=s1.nryears/inrange100;
                else
                    s1.return_period(ii,jj)=NaN;
                end
                inrange100=distances<=100;
                
                % Return period storms exceeding 50 kts
                vm=s.vmax;
                vm(isnan(vm))=0;
                vm(~inrange100)=0;
                vm=max(vm,[],2); % Determine maximum wind speed of each storm within range
                nrgt50=length(find(vm>=50));
                if nrgt50>0
                    s1.return_period_gt_50kts(ii,jj)=s1.nryears/nrgt50;
                else
                    s1.return_period_gt_50kts(ii,jj)=NaN;
                end
                
                % Return period storms exceeding 100 kts
                vm=s.vmax;
                vm(isnan(vm))=0;
                vm(~inrange100)=0;
                vm=max(vm,2);
                nrgt100=length(find(vm>=100));
                if nrgt100>0
                    s1.return_period_gt_100kts(ii,jj)=s1.nryears/nrgt100;
                else
                    s1.return_period_gt_100kts(ii,jj)=NaN;
                end
                
            else
                % Latitudes
                inrange=s.lat>yg(ii,1)-0.5*lat_search_range & s.lat<=yg(ii,1)+0.5*lat_search_range;
                ninrange=sum(sum(inrange));
                
            end
            
            
            if ninrange==0
                
                forward_speed           = [];
                forward_speed_change    = [];
                heading                 = [];
                heading_change          = [];
                vmax                    = [];
                vmax_change             = [];
                dvmax0                  = [];
                
            else
                
                %% First make vectors of data within search range
                % Forward speed
                u0=s.u0(inrange);
                v0=s.v0(inrange);
                u1=s.u1(inrange);
                v1=s.v1(inrange);
                
                % Get rid of NaNs
                u0(isnan(u1))=NaN;
                v0(isnan(v1))=NaN;
                u1(isnan(u0))=NaN;
                v1(isnan(v0))=NaN;
                
                u0=u0(~isnan(u0));
                v0=v0(~isnan(v0));
                u1=u1(~isnan(u1));
                v1=v1(~isnan(v1));
                
                spd0=sqrt(u0.^2+v0.^2);
                phi0=atan2(v0,u0);
                phi0=mod(phi0,2*pi);
                
                spd1=sqrt(u1.^2+v1.^2);
                phi1=atan2(v1,u1);
                phi1=mod(phi1,2*pi);
                
                dspd=spd1-spd0;
                dphi=phi1-phi0;
                dphi=dphi;
                idnegative = dphi<pi*-1;
                idpostive  = dphi>pi;
                dphi(idnegative)    = dphi(idnegative)+2*pi;
                dphi(idpostive)     = dphi(idpostive)-2*pi;
                
                forward_speed=spd0;
                forward_speed_change=dspd;
                
                % Foreward direction
                heading=phi0;
                heading_change=dphi;
                
                % Vmax
                vmax0=s.vmax0(inrange);
                vmax1=s.vmax1(inrange);
                vmax2=s.vmax2(inrange);
                vmax0=vmax0(~isnan(vmax0));
                vmax1=vmax1(~isnan(vmax1));
                vmax2=vmax2(~isnan(vmax2));
                
                vmax=vmax1;
                vmax_change=vmax2-vmax1;
                dvmax0=vmax1-vmax0;
                
            end
            
            %% Now do the statistics
            % Foreward speed
            s1.forward_speed_bins                               = forward_speed_bins;
            s1.(par)(ii,jj).forward_speed.occurences            = forward_speed;
            s1.(par)(ii,jj).forward_speed.number_of_occurences  = length(forward_speed);
            s1.(par)(ii,jj).forward_speed.mean                  = nanmean(forward_speed);
            s1.(par)(ii,jj).forward_speed.std                   = std(forward_speed);
            
            % Heading
            s1.heading_bins                                     = heading_bins;
            s1.(par)(ii,jj).heading.occurences                  = heading;
            s1.(par)(ii,jj).heading.number_of_occurences        = length(heading);
            s1.(par)(ii,jj).heading.mean                        = nanmean(heading);
            s1.(par)(ii,jj).heading.std                         = std(heading);
            
            % Observed
            if strcmpi(opt,'observed')

                %% Decoupled heading
                for iphi=1:length(heading_bins)
                    
                    % Filtering
                    if setting.kde.auto == 1
                        if iphi == 1
                            heading_search_range   = heading_bins(iphi+1) - heading_bins(iphi);
                        elseif iphi == length(heading_bins)
                             heading_search_range   = heading_bins(iphi) - heading_bins(iphi-1);
                        else
                            heading_search_range   = 0.5*(heading_bins(iphi+1) - heading_bins(iphi)) + 0.5*(heading_bins(iphi) - heading_bins(iphi-1));
                        end
                        heading_search_range        = heading_search_range*1.5;  % ensure a bit of overlap
                    else
                        heading_search_range        = setting.kde.heading_search_range;
                    end
                    mean_heading_bin        = heading_bins(iphi);
                    min_heading             = mean_heading_bin-heading_search_range;
                    max_heading             = mean_heading_bin+heading_search_range;
                    min_heading             = mod(min_heading,2*pi);
                    max_heading             = mod(max_heading,2*pi);
                    
                    % Find certain onces
                    if min_heading > max_heading
                        % since we 45 degrees bins this is possible
                        iinphi = (heading>=min_heading | heading<=max_heading);
                    else
                        % 'normally'
                        iinphi = (heading>=min_heading & heading<=max_heading);
                    end
                    
                    % Sort values
                    dphi            = heading_change(iinphi);
                    dphi            = dphi(~isnan(dphi));
                    dphi            = mod(dphi,2*pi);
                    dphi(dphi>pi)   = dphi(dphi>pi)-2*pi;
                    
                    % Get KDE of heading change
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).heading_median                   = median(heading(iinphi));
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).heading_mean_bin                 = mean_heading_bin;
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).heading_max_bin                  = max_heading;
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).heading_min_bin                  = min_heading;
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).occurences                       = dphi;
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).number_of_occurences             = length(dphi);
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).mean                             = mean(dphi);
                    s1.(par)(ii,jj).decoupled_heading_change(iphi).std                              = std(dphi);
                    if ~isempty(dphi)
                        if setting.deleteclosezeros_KDE(1) == 1
                            if length(unique(round(dphi.*10000)./10000))==1             % if close to zero
                                dphi=dphi(1);
                            end
                        end
                        if length(dphi) < min_number_of_points_KDE
                            s1.(par)(ii,jj).decoupled_heading_change(iphi).F = [];
                            s1.(par)(ii,jj).decoupled_heading_change(iphi).X = dphi;
                        else
                            f = kde(dphi, kde_options);
                            s1.(par)(ii,jj).decoupled_heading_change(iphi).F = f.f;
                            s1.(par)(ii,jj).decoupled_heading_change(iphi).X = f.x{1,1};
                        end
                    else
                        s1.(par)(ii,jj).decoupled_heading_change(iphi).F = [];
                        s1.(par)(ii,jj).decoupled_heading_change(iphi).X = [];
                    end
                    
                    % Delete occurances
                    if reduce_size == 1
                        s1.(par)(ii,jj).decoupled_heading_change(iphi).occurences   = [];
                    end
                end
                TMP = s1.(par)(ii,jj).decoupled_heading_change;
                
                
                %% Decouped forward bins
                for ispd=1:length(forward_speed_bins)
                    
                    % Filtering
                    if setting.kde.auto == 1
                        if ispd == 1
                            forward_search_range    = forward_speed_bins(ispd+1) - forward_speed_bins(ispd);
                        elseif ispd == length(heading_bins)
                            forward_search_range   = forward_speed_bins(ispd) - forward_speed_bins(ispd-1);
                        else
                            forward_search_range   = 0.5*(forward_speed_bins(ispd+1) - forward_speed_bins(ispd)) + 0.5*(forward_speed_bins(ispd) - forward_speed_bins(ispd-1));
                        end
                        forward_search_range        = forward_search_range*1.5; % ensure a bit of overlap
                    else
                        forward_search_range        = setting.kde.forward_search_range;
                    end
                    
                    % Define bin
                    mean_forward_speed_bin  = forward_speed_bins(ispd);
                    min_forward_speed       = mean_forward_speed_bin-forward_search_range;
                    max_forward_speed       = mean_forward_speed_bin+forward_search_range;
                    if ispd == length(forward_speed_bins)
                        max_forward_speed   = Inf;
                    end
                    if ispd == 1
                        min_forward_speed       = -Inf;
                    end
                    iinspd                  = find(forward_speed >= min_forward_speed & forward_speed <= max_forward_speed);
                    
                    % Sort values
                    dspd            = forward_speed_change(iinspd);
                    dspd            = dspd(~isnan(dspd));
                    
                    % Get KDE for forward speed change
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).forward_speed_median       = median(forward_speed(iinspd));
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).forward_speed_mean_bin     = mean_forward_speed_bin;
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).forward_speed_min_bin      = min_forward_speed;
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).forward_speed_max_bin      = max_forward_speed;
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).occurences                 = dspd;
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).number_of_occurences       = length(dspd);
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).mean                       = mean(dspd);
                    s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).std                        = std(dspd);
                    
                    if ~isempty(dspd)
                        if setting.deleteclosezeros_KDE(2) == 1
                            if length(unique(round(dspd.*10000)./10000))==1             % if close to zero
                                dspd=dspd(1);
                            end
                        end
                        if length(dspd) < min_number_of_points_KDE
                            s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).F = [];
                            s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).X = dspd;
                        else
                            f = kde(dspd, kde_options);
                            s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).F = f.f;
                            s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).X = f.x{1,1};
                        end
                    else
                        s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).F = [];
                        s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).X = [];
                    end
                    
                    % Delete occurances
                    if reduce_size == 1
                        s1.(par)(ii,jj).decoupled_forward_speed_change(ispd).occurences   = [];
                    end
                end
                TMP = s1.(par)(ii,jj).decoupled_forward_speed_change;

            end
            
            %% Maximum sustainted wind speeds (always decoupled)
            s1.vmax_bins                                    = vmax_bins;
            s1.(par)(ii,jj).vmax.occurences                 = vmax;
            s1.(par)(ii,jj).vmax.number_of_occurences       = length(vmax);
            s1.(par)(ii,jj).vmax.mean                       = nanmean(vmax);
            s1.(par)(ii,jj).vmax.std                        = std(vmax);
            
            if strcmpi(opt,'observed')
                for ivmax=1:length(vmax_bins)
                    
                    % Filtering
                    if setting.kde.auto == 1
                        if ivmax == 1
                            vmax_search_range       = vmax_bins(ivmax+1) - vmax_bins(ivmax);
                        elseif ivmax == length(vmax_bins)
                            vmax_search_range       = vmax_bins(ivmax) - vmax_bins(ivmax-1);
                        else
                            vmax_search_range       = 0.5*(vmax_bins(ivmax+1) - vmax_bins(ivmax)) + 0.5*(vmax_bins(ivmax) - vmax_bins(ivmax-1));
                        end
                        vmax_search_range        = vmax_search_range*1.5;
                    else
                        vmax_search_range        = setting.kde.vmax_search_range;
                    end
                                        
                    % Define bin
                    mean_vmax_bin       = vmax_bins(ivmax);
                    min_vmax            = mean_vmax_bin-vmax_search_range;
                    max_vmax            = mean_vmax_bin+vmax_search_range;
                    if ivmax == length(vmax_bins)
                        max_vmax        = Inf;
                    end
                    if ivmax == 1
                        min_vmax        = 0;
                    end
                    
                    % Sort values
                    iin                 = find(vmax>=min_vmax & vmax<=max_vmax);
                    dvmax               = vmax_change(iin);
                    dvmax               = dvmax(~isnan(dvmax));
                    
                    s1.(par)(ii,jj).vmax_change(ivmax).vmax_median   = median(vmax(iin));
                    s1.(par)(ii,jj).vmax_change(ivmax).vmax_mean_bin = mean_vmax_bin;
                    s1.(par)(ii,jj).vmax_change(ivmax).vmax_max      = max_vmax;
                    s1.(par)(ii,jj).vmax_change(ivmax).vmax_min      = min_vmax;
                    s1.(par)(ii,jj).vmax_change(ivmax).occurences    = dvmax;
                    s1.(par)(ii,jj).vmax_change(ivmax).number_of_occurences=length(dvmax);
                    s1.(par)(ii,jj).vmax_change(ivmax).mean          = mean(dvmax);
                    s1.(par)(ii,jj).vmax_change(ivmax).std           = std(dvmax);
                    if ~isempty(dvmax)
                        if setting.deleteclosezeros_KDE(3) == 1
                            if length(unique(round(dvmax*10000)/10000))==1              % if close to zero
                                dvmax   = dvmax(1);
                            end
                        end
                        if length(dvmax) < min_number_of_points_KDE
                            s1.(par)(ii,jj).vmax_change(ivmax).F = [];       % this should happen since points > min points KDE
                            s1.(par)(ii,jj).vmax_change(ivmax).X = dvmax;
                        else
                            f = kde(dvmax, kde_options);
                            s1.(par)(ii,jj).vmax_change(ivmax).F = f.f;
                            s1.(par)(ii,jj).vmax_change(ivmax).X = f.x{1,1};
                        end
                    else
                        s1.(par)(ii,jj).vmax_change(ivmax).F = [];       % this could happen since points > min points KDE
                        s1.(par)(ii,jj).vmax_change(ivmax).X = [];
                    end
                end
                
                % Reduce size
                if reduce_size == 1
                    s1.(par)(ii,jj).vmax_change(ivmax).occurences = [];
                end
                TMP = s1.(par)(ii,jj).vmax_change;

            end
        end
    end
end

% % Check for empty latitudes, should be filled with data from other
% % latitudes to avoid empty bins
% if strcmpi(opt,'observed') && lat_filling == 1
%     disp(['    filling empty latitudes']);
%     emptyvmax=zeros(length(s1.(par)),length(vmax_bins)-1);
%     emptyvmax(emptyvmax==0)=NaN;
%     vmaxocc=emptyvmax;
%     lat=s1.(par);
%     for i=1:length(s1.(par))
%
%         % First for vmax
%         for j=length(vmax_bins):-1:1
%             imin=i;iplus=i;
%             iminocc=[];iplusocc=[];oldocc=[];
%             while length(s1.(par)(i).vmax_change(j).occurences)< min_number_of_points_KDE
%                 imin=imin-1;
%                 iplus=iplus+1;
%                 if imin < 1 && iplus > length(s1.(par))
%                     emptyvmax(i,j)=1;
%                     break
%                 end
%                 if imin>=1
%                     iminocc=lat(imin).vmax_change(j).occurences;
%                 end
%                 if iplus<=length(s1.(par))
%                     iplusocc=lat(iplus).vmax_change(j).occurences;
%                 end
%                 oldocc=s1.(par)(i).vmax_change(j).occurences;
%                 [~,~,IB] =intersect(oldocc,iminocc);
%                 iminocc(IB)=[];
%                 [~,~,IB] =intersect(oldocc,iplusocc);
%                 iplusocc(IB)=[];
%                 s1.(par)(i).vmax_change(j).occurences=vertcat(iminocc,iplusocc,oldocc);
%             end
%             if ~isempty(s1.(par)(i).vmax_change(j).occurences)
%                 if length(unique(round(s1.(par)(i).vmax_change(j).occurences*10000)/10000))==1
%                     s1.(par)(i).vmax_change(j).occurences=s1.(par)(i).vmax_change(j).occurences(1);
%                 end
%                 if length(s1.(par)(i).vmax_change(j).occurences) < 2        % this should not happen
%                     s1.(par)(i).vmax_change(j).F = 1;
%                     s1.(par)(i).vmax_change(j).X = s1.(par)(i).vmax_change(j).occurences(1);
%                 else
%                     f = kde(s1.(par)(i).vmax_change(j).occurences);
%                     s1.(par)(i).vmax_change(j).F = f.f;
%                     s1.(par)(i).vmax_change(j).X = f.x{1,1};
%                 end
%             end
%             vmaxocc(i,j)=length(s1.(par)(i).vmax_change(j).occurences);
%         end
%
%         % Now for phi and c
%         for j=length(forward_speed_bins):-1:1
%             for k=length(heading_bins):-1:1
%                 imin=i;iplus=i;
%                 headiminocc=[];headiplusocc=[];headoldocc=[];
%                 speediminocc=[];speediplusocc=[];speedoldocc=[];
%                 while length(s1.(par)(i).vector(j,k).heading_change.occurences)<min_number_of_points_KDE
%                     imin=imin-1;
%                     iplus=iplus+1;
%                     if imin < 1 && iplus > length(s1.(par))
%                         break
%                     end
%                     if imin>=1
%                         headiminocc=lat(imin).vector(j,k).heading_change.occurences;
%                         speediminocc=lat(imin).vector(j,k).forward_speed_change.occurences;
%                     else
%                         headiminocc=[];
%                         speediminocc=[];
%                     end
%                     if iplus<=length(s1.(par))
%                         headiplusocc    = lat(iplus).vector(j,k).heading_change.occurences;
%                         speediplusocc   = lat(iplus).vector(j,k).forward_speed_change.occurences;
%                     else
%                         headiplusocc=[];
%                         speediplusocc=[];
%                     end
%                     headoldocc=s1.(par)(i).vector(j,k).heading_change.occurences;
%                     [~,~,IB] =intersect(headoldocc,headiminocc);
%                     headiminocc(IB)=[];
%                     [~,~,IB] =intersect(headoldocc,headiplusocc);
%                     headiplusocc(IB)=[];
%
%                     speedoldocc=s1.(par)(i).vector(j,k).forward_speed_change.occurences;
%                     [~,~,IB] =intersect(speedoldocc,speediminocc);
%                     speediminocc(IB)=[];
%                     [~,~,IB] =intersect(speedoldocc,speediplusocc);
%                     speediplusocc(IB)=[];
%                     s1.(par)(i).vector(j,k).heading_change.occurences=vertcat(headiminocc,headiplusocc,headoldocc);
%                     s1.(par)(i).vector(j,k).forward_speed_change.occurences=vertcat(speediminocc,speediplusocc,speedoldocc);
%                 end
%                 if ~isempty(s1.(par)(i).vector(j,k).heading_change.occurences)
%                     if length(unique(round(s1.(par)(i).vector(j,k).heading_change.occurences*10000)/10000))==1
%                         s1.(par)(i).vector(j,k).heading_change.occurences=s1.(par)(i).vector(j,k).heading_change.occurences(1);
%                     end
%                     if length(s1.(par)(i).vector(j,k).heading_change.occurences) < min_number_of_points_KDE            % this should not happen but can
%                         s1.(par)(i).vector(j,k).heading_change.F = [];
%                         s1.(par)(i).vector(j,k).heading_change.X = s1.(par)(i).vector(j,k).heading_change.occurences(1);
%                     else
%                         f = kde(s1.(par)(i).vector(j,k).heading_change.occurences);
%                         s1.(par)(i).vector(j,k).heading_change.F = f.f;
%                         s1.(par)(i).vector(j,k).heading_change.X = f.x{1,1};
%                     end
%                 end
%                 if ~isempty(s1.(par)(i).vector(j,k).forward_speed_change.occurences)
%                     if length(unique(round(s1.(par)(i).vector(j,k).forward_speed_change.occurences*10000)/10000))==1
%                         s1.(par)(i).vector(j,k).forward_speed_change.occurences=s1.(par)(i).vector(j,k).forward_speed_change.occurences(1);
%                     end
%                     if length(s1.(par)(i).vector(j,k).forward_speed_change.occurences) < min_number_of_points_KDE     % this should not happen but can
%                         s1.(par)(i).vector(j,k).forward_speed_change.F = [];
%                         s1.(par)(i).vector(j,k).forward_speed_change.X = s1.(par)(i).vector(j,k).forward_speed_change.occurences(1);
%                     else
%                         f = kde(s1.(par)(i).vector(j,k).forward_speed_change.occurences);
%                         s1.(par)(i).vector(j,k).forward_speed_change.F = f.f;
%                         s1.(par)(i).vector(j,k).forward_speed_change.X = f.x{1,1};
%                     end
%                 end
%             end
%         end
%     end
% end

% Save pdf-file
disp('    saving PDF file');
try
    delete(pdffile)
catch
end
save(pdffile,'-struct','s1', '-v7.3');


%% Also store maps
s=[];
n=0;
vmaxmean=zeros(size(xg));
vmaxmean(vmaxmean==0)=NaN;
vmaxstd=vmaxmean;
umean=vmaxmean;
vmean=vmaxmean;

for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        vmaxmean(ii,jj)=s1.location(ii,jj).vmax.mean;
        vmaxstd(ii,jj)=s1.location(ii,jj).vmax.std;
        mag=s1.location(ii,jj).forward_speed.occurences;
        phi=s1.location(ii,jj).heading.occurences;
        u=mag.*cos(phi);
        v=mag.*sin(phi);
        umean(ii,jj)=mean(u);
        vmean(ii,jj)=mean(v);
    end
end

n=n+1;
s.parameters(n).parameter.name='Return period (total)';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.val=s1.return_period;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='scalar';

n=n+1;
s.parameters(n).parameter.name='Return period >50kts';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.val=s1.return_period_gt_50kts;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='scalar';

n=n+1;
s.parameters(n).parameter.name='Return period >100kts';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.val=s1.return_period_gt_100kts;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='scalar';

n=n+1;
s.parameters(n).parameter.name='Vmax (mean)';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.val=vmaxmean;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='scalar';

n=n+1;
s.parameters(n).parameter.name='Vmax (standard deviation)';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.val=vmaxstd;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='scalar';

n=n+1;
s.parameters(n).parameter.name='Mean motion vector';
s.parameters(n).parameter.x=xg;
s.parameters(n).parameter.y=yg;
s.parameters(n).parameter.u=umean;
s.parameters(n).parameter.v=vmean;
s.parameters(n).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
s.parameters(n).parameter.quantity='vector';

try
    delete(mapsfile)
catch
end
save(mapsfile,'-struct','s', '-v7.3');

%% Figures
for n = 1:length(s.parameters)
    
    % Get values
    if strcmp(s.parameters(n).parameter.quantity, 'scalar')
        xg  = s.parameters(n).parameter.x;
        yg  = s.parameters(n).parameter.y;
        val = s.parameters(n).parameter.val;
    else
        xg  = s.parameters(n).parameter.x;
        yg  = s.parameters(n).parameter.y;
        u   = s.parameters(n).parameter.u;
        v   = s.parameters(n).parameter.v;
    end
    
    % Header
    Yfig = 29.7/2;   XFig = 21.0;
    xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
    hFig = figure('visible','off'); hold on;
    set(hFig, 'PaperUnits','centimeters');
    set(hFig, 'PaperSize',[XFig Yfig]);
    set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
    set(hFig, 'PaperOrientation','portrait');
    
    % Plotting
    if strcmp(s.parameters(n).parameter.quantity, 'scalar')
        pcolor(xg,yg,val);shading flat;colorbar;colormap(jet);title(s.parameters(n).parameter.name)
    else
        quiver(xg,yg,u,v);
    end
    axis equal
    xlim([min(min(xg)) max(max(xg))]);
    ylim([min(min(yg)) max(max(yg))]);
    plot(xldb,yldb,'k')
    ylabel('latitude [°]')
    xlabel('longitude [°]')
    grid on; box on;
    mkdir([dir '\', opt]);
    print([dir '\', opt, '\Figure', num2str(n), '.png'],'-dpng'  ,'-r288');
end

% Plot how full
for ii = 1:size(s1.location,1)
    for jj = 1:size(s1.location,2)
        information_box(ii,jj)  = nanmean(diff(s1.location(ii,jj).information_box'));
        ninrange(ii,jj)         = s1.location(ii,jj).ninrange;
    end
end

% Information box / # points
information_box(information_box ==0)    = NaN;
ninrange(ninrange ==0)                  = NaN;
s1.information_box                      = information_box;
s1.ninrange                             = ninrange;

close all
Yfig = 29.7/2;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off');
hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');
pcolor(s1.xg, s1.yg, ninrange); shading flat;
plot(xldb, yldb, 'k');
axis equal
colormap(jet)
xlim([min(min(xg)) max(max(xg))]);
ylim([min(min(yg)) max(max(yg))]);
plot(xldb,yldb,'k')
ylabel('latitude [°]')
xlabel('longitude [°]')
grid on; box on;
mkdir([dir '\', opt]);
hc = colorbar;
ylabel(hc, 'data points in KDE [-]');
print([dir '\', opt, '\Figure', num2str(n+1), '.png'],'-dpng'  ,'-r288');


close all
Yfig = 29.7/2;   XFig = 21.0;
xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
hFig = figure('visible','off');
hold on;
set(hFig, 'PaperUnits','centimeters');
set(hFig, 'PaperSize',[XFig Yfig]);
set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
set(hFig, 'PaperOrientation','portrait');
pcolor(s1.xg, s1.yg, information_box); shading flat;
plot(xldb, yldb, 'k');
axis equal
xlim([min(min(xg)) max(max(xg))]);
ylim([min(min(yg)) max(max(yg))]);
plot(xldb,yldb,'k')
ylabel('latitude [°]')
xlabel('longitude [°]')
grid on; box on;
mkdir([dir '\', opt]);
hc = colorbar;
ylabel(hc, 'size of window [\circ]');
print([dir '\', opt, '\Figure', num2str(n+2), '.png'],'-dpng'  ,'-r288');

% %% Analysis of how full everthing is
% % First for vmax
% filled_matrix = zeros(size(s1.location));
% for ii = 1:size(s1.location,1)
%     for jj = 1:size(s1.location,2)
%         for xx = 1:length(s1.location(ii,jj).vmax_change)
%             if length(s1.location(ii,jj).vmax_change(xx).occurences)>min_number_of_points_KDE
%                 filled_matrix(ii,jj) = filled_matrix(ii,jj)+1;
%             end
%         end
%     end
% end
% figure; pcolor(xg,yg, filled_matrix); shading flat;
% print([dir '\', opt, '\Figure_vmax_occur.png'],'-dpng'  ,'-r288');
%
% % Second for vector
% filled_matrix = zeros(size(s1.location));
% for ii = 1:size(s1.location,1)
%     for jj = 1:size(s1.location,2)
%         for x1 = 1:size(s1.location(ii,jj).vector,1)
%             for x2= 1:size(s1.location(ii,jj).vector,2)
%             if length(s1.location(ii,jj).vector(x1,x2).forward_speed_change.occurences)>min_number_of_points_KDE
%                 filled_matrix(ii,jj) = filled_matrix(ii,jj)+1;
%             end
%             if length(s1.location(ii,jj).vector(x1,x2).heading_change.occurences)>min_number_of_points_KDE
%                 filled_matrix(ii,jj) = filled_matrix(ii,jj)+1;
%             end
%         end
%     end
%     end
% end
% figure; pcolor(xg,yg, filled_matrix); shading flat;
% print([dir '\', opt, '\Figure_vector_occur.png'],'-dpng'  ,'-r288');
% close all


