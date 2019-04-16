%% LSU: mainloop D3D - XBeach coupling
% v1.3  Nederhoff   Aug-18
% v1.4  Nederhoff   Sep-18
% v1.5  Johnson     Nov-18
% v1.5.1 Johnson    Jan-19

%% prepare environment
clear all;
close all;
clc;
addpath('/work/cjoh296/matlab/oet');
oetsettings;
addpath('/home/cjoh296/matlab'); %overide oet functions xb_swan_write, xb_swan_coords, trirst
warning off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model setups
home_dir        = pwd                                                           ;
d3d_mdf         = 'barrier'                                                     ;
restart_name    = 'tri-rst.barrier'                                             ;
path_d3d_in     = '/work/cjoh296/delft3d_xbeach_coupling.wd/testing/01_delft3d' ;
path_XB_in      = '/work/cjoh296/delft3d_xbeach_coupling.wd/testing/02_xbeach'  ;
path_out        = '/work/cjoh296/delft3d_xbeach_coupling.wd/testing/output'     ;

delft3d_CRS     = 'WGS 84'                                                      ;
xbeach_CRS      = 'WGS 84 / UTM zone 15N'                                       ;


% Coupling setup options
morpho_update   = 1 ; % turns off morpho in delft3d and xb
change_restart  = 1 ; % keep this option on. if off, then the restart file is copied
HS_XB_threshold = 0 ; % this is wave height in meters. when delft3d results exceed this value switch to xb


% Time management
Itdate_jd         = datenum(2008, 7, 25)                ;  % julian day for Itdate
simulation_dur    = 11520*60                            ;  % [s] simulation duration
dt_coupling       = 10*60                               ;  % [s] coupling xbeach/delft3d timestep
timesteps         = simulation_dur / dt_coupling        ;  % number of delft3d runs
time_start        = '20080828.000000'                   ;  % yyyymmdd
time_start_offset = 48960*60                            ;  % [s] start of delft3d from Itdate
dt_times          = ones(timesteps, 1) * dt_coupling    ;  % [s]   so 10 minutes = 10 x 60 = 600 s
%dt_times(1)       = 60*60*6                             ;  % [s]   spin-up time for Delft3D. inputs/BCs need to reflect this
%mor_start         = dt_times(1)                         ;  % [s]   D3D spinup
mor_start         = 0                                   ;
spinup_xb         = 600                                 ;  % [s]   model schematization dependent


% profiling
profile_table_fn = [path_out, '/comp_times.mat'];
varTypes = {'int16', 'double', 'double', 'double'};
varNames =  {'dt', 'matlab', 'XB', 'D3D'};
comp_times        = zeros(timesteps, 4);
T_matlab          = 0;
T_XB              = 0;
T_D3D             = 0;

% use SuperMIC
use_smic        = 1;

% Calculation H6
useh6           = 0;
user            = 'nederhof';
pass            = 'pllcmn2018!';
type            = 'normal-e5';
plink           = 'p:\11200397-lsu-xbeach-delft3d4\04_conceptual\03_running_scripts\plink.exe';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Beginning coupling script.') ;
disp('Initializizing...')          ;

% start initial time step matlab clock
tic;

d3d_grid_fn     = [path_d3d_in, '/barrier.grd']; 
grd1            = wlgrid('read', d3d_grid_fn); 
grd2            = delft3d_io_grd('read', d3d_grid_fn);
nx              = grd2.nmax;
ny              = grd2.mmax;

% Get more type of grids
[cen.x, cen.y]  = convertCoordinates(grd2.cen.x, grd2.cen.y,'CS1.name', delft3d_CRS,'CS1.type','geo', 'CS2.name', xbeach_CRS,'CS2.type','xy');
[cor.x, cor.y]  = convertCoordinates(grd2.cor.x, grd2.cor.y,'CS1.name', delft3d_CRS,'CS1.type','geo', 'CS2.name', xbeach_CRS,'CS2.type','xy');
[u.x, u.y]      = convertCoordinates(grd2.u.x, grd2.u.y,'CS1.name', delft3d_CRS,'CS1.type','geo', 'CS2.name', xbeach_CRS,'CS2.type','xy');
[v.x, v.y]      = convertCoordinates(grd2.v.x, grd2.v.y,'CS1.name', delft3d_CRS,'CS1.type','geo', 'CS2.name', xbeach_CRS,'CS2.type','xy');


% calculate distances between XB and D3D grid points
xb_grid_fn      = [path_XB_in, '/xy.grd'];
[xb_x, xb_y]    = wlgrid('read', xb_grid_fn);
xb_x            = xb_x';
xb_y            = xb_y';
for jj = 1:(nx-2)
	for ii = 1:(ny-2)

		% check for valid grid cell
		if ~isnan(cen.x(jj,ii)) && ~isnan(cen.y(jj,ii))
		
			% Check distance
			[index, distance(jj,ii), twoout] = nearxy(xb_x(:), xb_y(:), cen.x(jj,ii), cen.y(jj,ii));

		end

	end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(path_out);   % directory on the cluster
for dt = 1:timesteps


    % Print information on coupling time step and simulation datetime
    if dt == 1
        totalduration   = sum(dt_times)/60/60/24                                ; % in days
        dstr = sprintf('Total simulation time (days): %11.2f\n', totalduration) ;
		disp(dstr)                                                              ;
        dt_time     = dt_times(dt)                                              ;
        time_now    = 0                                                         ;
        time_going  = dt_time                                                   ;
		jd_now      = Itdate_jd + time_start_offset/60/60/24                    ;
    else
        dt_time     = dt_times(dt)                                              ;
        time_now    = time_now + dt_times(dt-1)                                 ;
        time_going  = time_going + dt_times(dt)                                 ;
		jd_now      = Itdate_jd + (time_now + time_start_offset)/60/60/24       ;
    end

	dstr = sprintf('Working on: %21u of %u', [dt, timesteps])                   ;
	disp(dstr)                                                                  ;

	dstr = sprintf('Simulation datetime: %20s\n', datestr(jd_now))              ;
	disp(dstr)                                                                  ;




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Part 1: Copy D3D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	% A. Copy original setup files to incremental D3D run directory
	cd(path_out)                                                                    ;
	D3D_run_num  = ['D3D_', num2str(dt, '%04d')]                                    ;
    path_d3d_new = [path_out, '/D3D_' num2str(dt, '%04d')]                          ;
    mkdir(path_d3d_new)                                                             ;
	cd(path_d3d_new)                                                                ;
    copyfile(path_d3d_in, pwd)                                                      ;

	dstr = sprintf('Entering incremental Delft3D directory:\n\t%s\n', path_d3d_new) ;
	disp(dstr)                                                                      ;


	% Replace time parameters in incremental mdf file
    cd(path_d3d_new)                                                                ;
    fid = fopen([d3d_mdf, '.mdf'], 'rt')                                            ;
    X   = fread(fid)                                                                ;
    fclose(fid)                                                                     ;
    X = char(X.')                                                                   ;


    % Replace restart file time stamp with current dt
    format_st       = 'YYYYmmdd.HHMMSS'                                             ;
    datetime_start  = datenum(time_start, format_st)                                ;
    datetime_now    = datetime_start + time_now/60/60/24                            ;
    text_to_search  = ['#' , time_start , '#']                                      ;
    text_to_replace = ['#' , datestr(datetime_now, format_st) , '#']                ;
    X = strrep(X, text_to_search, text_to_replace)                                  ;


    % Replace start time
    text_to_search  = 'TTSTART'                                                     ;
    text_to_replace_start = [' ', num2str((time_now + time_start_offset)/60), ' ']  ;
    X = strrep(X, text_to_search, text_to_replace_start)                            ;


    % Replace end time
    text_to_search  = 'TTSTOP'                                                      ;
    text_to_replace_stop = [' ', num2str((time_going + time_start_offset)/60), ' '] ;
    X = strrep(X, text_to_search, text_to_replace_stop)                             ;


    % Safe new MDF
    fid2 = fopen([d3d_mdf, '.mdf'],'wt')                                            ;
    fwrite(fid2,X)                                                                  ;
    fclose (fid2)                                                                   ;
    fclose('all')                                                                   ;


	% Log changes
	dstr = sprintf('%s.mdf was modified for timestep: %04u', d3d_mdf, dt)           ;
	disp(dstr)                                                                      ;
	
	dstr = sprintf('TTSTART was replaced with: %17s', text_to_replace_start)        ;
	disp(dstr)                                                                      ;

	dstr = sprintf('TTSTOP was replaced with: %18s\n', text_to_replace_stop)        ;
	disp(dstr)                                                                      ;
    
    % log matlab time
    T_matlab = T_matlab + toc;



	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % B. Process previous time step results for D3D and XB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if dt > 1
        
        % start Matlab clock
        tic;


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% Processes Delft3d output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Copy restart file
        path_d3d_old = [path_out, '/D3D_' num2str(dt-1, '%04d')];
        cd(path_d3d_old);
        S = dir([restart_name, '.', datestr(datetime_now, format_st)]) ;
        copyfile(S.name, [path_d3d_new, '/tri-rst.' datestr(datetime_now, format_st)]);


        % Copy hotstart from SWAN
        % if there are waves in it!
        d3d_nc      = ['trih-', d3d_mdf , '.dat'];
        Fil         = qpfopen(d3d_nc);
        tmp5        = qpread(Fil,'significant wave height','data',0,[1]);

        if mean(tmp5.Val) > 0.5
            S = dir(['hot_1_', datestr(datetime_now, format_st)]) ;
            copyfile(S.name, [path_d3d_new, '/hot_1_00000000.000000']);
            S = dir(['hot_2_', datestr(datetime_now, format_st)]) ;
            copyfile(S.name, [path_d3d_new, '/hot_2_00000000.000000']);
        end

        % Delete hotstart (to safe space)
        cd(path_d3d_old);
        listing = dir('hot*');
        for qaz = 1:length(listing)
            delete(listing(qaz).name);
        end

		% log processing output
		dstr = ['Processing sediment transport for time step: ', num2str(dt)] ;
		disp(dstr)                                                           ;

        % Get Delft3D grid
        cd(path_d3d_old)

        % Get changed bathymetry based on XBeach results
        if morpho_update == 1 && mor_start <= time_now

            % Get Delft3D-computed sediment transport: we use the last time
            % step otherwise transport underestimated
            cd(path_d3d_old)
            Fil                         = (['trim-', d3d_mdf, '.dat']);
            H                           = vs_use(Fil);
            totaltime                   = qpread(H,'depth averaged velocity','times');
            SBu                         = vs_get(H, 'map-sed-series', {length(totaltime)},'SBUU',{[1:nx], [1:ny], [1]});
            SBv                         = vs_get(H, 'map-sed-series', {length(totaltime)},'SBVV',{[1:nx], [1:ny], [1]});
            SSu                         = vs_get(H, 'map-sed-series', {length(totaltime)},'SSUU',{[1:nx], [1:ny], [1]});
            SSv                         = vs_get(H, 'map-sed-series', {length(totaltime)},'SSVV',{[1:nx], [1:ny], [1]});
            Sutot_D3D                   = SBu + SSu;
            Svtot_D3D                   = SBv + SSv;

            % Get the sediment transport from XBeach
            if xb_previous == 1

                path_XB_old = [path_out, '/XB_' num2str(dt-1, '%04d')];
                cd(path_XB_old)
                xb_Su       = nc_varget('xboutput.nc', 'Sutot_mean');       xb_Su = squeeze(xb_Su(end,:,:));
                xb_Sv       = nc_varget('xboutput.nc', 'Svtot_mean');       xb_Sv = squeeze(xb_Sv(end,:,:));
                Fu          = scatteredInterpolant(xb_x(:), xb_y(:), xb_Su(:), 'natural', 'none');
                Fv          = scatteredInterpolant(xb_x(:), xb_y(:), xb_Sv(:), 'natural', 'none');

                % Determine Sutot en Svtot for Delft3D based on XBeach
                nsteps      = 100;
                Sutot_XB    = zeros(size(Sutot_D3D));
                Svtot_XB    = zeros(size(Svtot_D3D));
                for jj = 1:(nx-2)
                    for ii = 1:(ny-2)

						% check for valid grid cell
						if ~isnan(cen.x(jj,ii)) && ~isnan(cen.y(jj,ii))
							
							% Check distance
							if distance(jj,ii) < 1000 % in meters. need to experiment with this threshold

								% Get transects
								xlineu = linspace(cor.x(jj,  ii), cor.x(jj+1,     ii), nsteps);
								ylineu = linspace(cor.y(jj,  ii), cor.y(jj+1,     ii), nsteps);
								xlinev = linspace(cor.x(jj,  ii), cor.x(jj,       ii+1), nsteps);
								ylinev = linspace(cor.y(jj,  ii), cor.y(jj,       ii+1), nsteps);

								% Compute Su and Sv
								Su_TMP  = Fu(xlineu,ylineu);
								Sv_TMP  = Fv(xlinev,ylinev);

								% Average on the transect, OK since its equidistant
								Sutot_XB(jj,ii) = mean(Su_TMP);
								Svtot_XB(jj,ii) = mean(Sv_TMP);
							else
								Sutot_XB(jj,ii) = 0;
								Svtot_XB(jj,ii) = 0;
							end

                        else
                            Sutot_XB(jj,ii) = 0;
                            Svtot_XB(jj,ii) = 0;
                        end

                    end
                end
                % Take out NaNs
                idchange    = isnan(Sutot_XB);    Sutot_XB(idchange) = 0;
                idchange    = isnan(Svtot_XB);    Svtot_XB(idchange) = 0;

                % Create 'weight' for XB
                weight      = zeros(size(Sutot_D3D));
                id          = abs(Sutot_XB) > 0;
                weight(id)  = 1;
                weight      = smooth2(weight, 'box', [9]);

            else
                Sutot_XB    = zeros(size(Sutot_D3D));
                Svtot_XB    = zeros(size(Svtot_D3D));
                weight      = zeros(size(Sutot_D3D));
            end

            % Combine D3D and XB
            Sutot           = Sutot_D3D .* (1-weight) + Sutot_XB .* (weight);
            Svtot           = Svtot_D3D .* (1-weight) + Svtot_XB .* (weight);

            % Compute bottom changes
            clear duvdt da dzdt
            for jj = 1:(nx-2)
                for ii = 1:(ny-2)

                    % Get sediment transport
                    % For cell center (1,1), you need Su(1,1) and Su(1,2)
                    jjsed              = jj+1;
                    iised              = ii+1;
                    du1                = Sutot(jjsed,iised-1);
                    du2                = Sutot(jjsed,iised);
                    dv1                = Svtot(jjsed-1,iised);
                    dv2                = Svtot(jjsed,iised);

                    % Compute cell widths
                    dux1               = sqrt((cor.x(jj,  ii)     - cor.x(jj+1,     ii)).^2     + (cor.y(jj,    ii)     - cor.y(jj+1,       ii)).^2);
                    dux2               = sqrt((cor.x(jj,  ii+1)   - cor.x(jj+1,     ii+1)).^2   + (cor.y(jj,    ii+1)   - cor.y(jj+1,       ii+1)).^2);
                    dvx1               = sqrt((cor.x(jj,  ii)     - cor.x(jj,       ii+1)).^2   + (cor.y(jj,    ii)     - cor.y(jj,         ii+1)).^2);
                    dvx2               = sqrt((cor.x(jj+1,ii)     - cor.x(jj,       ii+1)).^2   + (cor.y(jj+1,    ii)   - cor.y(jj+1,       ii+1)).^2);

                    % Compute changes
                    duvdt(jj,ii)       = (du1 * dux1) - (du2 * dux2) +  (dv1 * dvx1) -  (dv2 * dvx2);       % [m3/s] since we multiplied with cell width
                    transport(jj,ii)   = sqrt(mean([du1, du2]).^2 + mean([dv1, dv2]).^2);                   % for plotting purposes
                    da(jj,ii)          = mean([dux1, dux2]) *  mean([dvx1, dvx2]);                          % compute area of cell
                    dm3dt(jj,ii)       = duvdt(jj,ii)  * dt_time;                                           % [m3]
                    dzdt(jj,ii)        = dm3dt(jj,ii)  / da(jj,ii);                                         % [m] !! right now porosity == 0
                end
            end

            % Limit dzdt (is this even needed?; hopefully not)
            %id_high = dzdt > 1;     dzdt(id_high) = -1;
            %id_low  = dzdt <-1;     dzdt(id_low) = -1;

            % Determine new bathy
            cd(path_d3d_old)
            dep2        = delft3d_io_dep('read', 'barrier.dep', grd2, 'location', 'cen');
            dep         = dep2.cen.dep;
            znew        = dep - dzdt;
            znew_flipped= znew';

            % Read restart file
            if change_restart == 1
                FILENAME = [path_d3d_new, '/tri-rst.' datestr(datetime_now, format_st)];
                X        = trirst('read',FILENAME,grd1,'all');
                WL       = X(1).Data([2:size(grd1.X,1)], [2:size(grd1.X,2)]);
                hhold    = dep' - WL;
                hhnew    = znew' - WL;
                ratiohh  = hhnew./hhold;

                % Change water levels
                [iderodedcell] = (hhnew >= 0.001 & hhold < 0.001);
                [iderodedcell1, iderodedcell2] = find(hhnew >= 0.0 & hhold <= 0);
                WL(iderodedcell1, iderodedcell2) = NaN;
                for xijn = 1:length(iderodedcell1);

                    % Point
                    xTMP    = grd2.cen.x(iderodedcell1(xijn), iderodedcell2(xijn));
                    yTMP    = grd2.cen.y(iderodedcell1(xijn), iderodedcell2(xijn));

                    % Main grid
                    xTMPs   = grd2.cen.x;
                    yTMPs   = grd2.cen.y;
                    iddry   = find(hhold < 0.01 | hhnew < 0.01);
                    xTMPs(iddry) = NaN;
                    yTMPs(iddry) = NaN;

                    % Find nearest wet point
                    distances = sqrt((xTMPs - xTMP).^2 + (yTMPs - yTMP).^2);
                    idnearest = find(distances == min(min(distances)));
                    WL(iderodedcell1, iderodedcell2) = WL(idnearest);
                end
                WL = internaldiffusion(WL);
                X(1).Data([2:size(grd1.X,1)], [2:size(grd1.X,2)])   = WL;

                % Change flow velocities and concentration (fluxes are constant)
				% The change is made based on the ratio of new to old water depth interpolated at the grid cell centers.
				ratiohh = ratiohh';
                
				% for real grids we must remove invalid grid points to perform interpolation
				valid_grid = ~isnan(grd2.cen.x) & ~isnan(grd2.cen.y) & ~isnan(ratiohh);

                ratiohh_u   = griddata(grd2.cen.x(valid_grid), ...  
				                       grd2.cen.y(valid_grid), ...
						               ratiohh(valid_grid), ...
							           grd2.u_full.x, ...
							           grd2.u_full.y);
				ratiohh_u(isnan(ratiohh_u)) = 1;
                
				ratiohh_v   = griddata(grd2.cen.x(valid_grid), ...
				                       grd2.cen.y(valid_grid), ...
									   ratiohh(valid_grid), ...
									   grd2.v_full.x, ...
									   grd2.v_full.y);
				ratiohh_v(isnan(ratiohh_v)) = 1;

                X(2).Data   = X(2).Data.*ratiohh_u'; % u velocity
                X(3).Data   = X(3).Data.*ratiohh_v'; % v velocity
				
				ratiohh(isnan(ratiohh)) = 1;
                X(4).Data([2:size(grd1.X,1)], [2:size(grd1.X,2)])   =  X(4).Data([2:size(grd1.X,1)], [2:size(grd1.X,2)]) .* ratiohh'; % constituent 1

				X(4).Data(isnan(X(4).Data)) = 0;

                % Save new restart file
                X        = trirst('write',FILENAME,X(1), X(2), X(3), X(4), X(5), X(6));
            end

            % See some figures of the changes
            %tempfigures = 0;
            %if tempfigures == 1
            %    close all
            %    figure; pcolor(dep);            shading flat;       caxis([-2 +5]); colormap(jet);
            %    figure; pcolor(znew);           shading flat;       caxis([-2 +5]); colormap(jet);
            %    figure; pcolor(znew-dep);       shading flat;       caxis([-0.0005 +0.0005]); colormap(jet);
            %    title('negative bottom goes up, hence d3d has a depth')

            %    figure; hold on;
            %    transectwanted = 94;
            %    plot(WL(transectwanted,:))
            %    plot(WLnew(transectwanted,:))
            %    plot(dep(:,transectwanted)*-1)
            %    plot(znew(:,transectwanted)*-1)
            %    legend('wl previous', 'wl now', 'dep previous', 'dep now')

            %    figure; pcolor(WL);             shading flat;
            %    figure; pcolor(WLnew);          shading flat;
            %    figure; pcolor(WLnew-WL);       shading flat;
            %end

            % Create new bathymetry
            cd(path_d3d_new);
            filename    = ['barrier.dep'];
            DP          = znew;
            DP = [-999*ones(1,size(DP,2)); DP; -999*ones(1,size(DP,2))];
            DP = [-999*ones(1,size(DP,1)); DP'; -999*ones(1,size(DP,1))];
            wldep('write',filename,DP)
		
			% log processing output
			dstr = sprintf('Time elapsed for sediment transport processing (min): %.2f\n\n', toc/60);
			disp(dstr)                                                                      ;
        end
        
        % log matlab time
        T_matlab = T_matlab + toc;
    end





    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Submit D3D HPC job %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% For use with Deltares' cluster
    if useh6 == 1
        runname         = ['LSU_D', num2str(dt, '%04d')];
        path            = path_d3d_new;
        [ output_args ] = ddb_NestingToolbox_submitH6(path,'delft3dfw',runname,d3d_mdf, user,pass, plink,type) ;
        running         = 1;
        while running == 1
            cd(path_d3d_new);
            if exist('finished.txt') > 0
                running = 0;
            end
            pause(1);
        end


	% Used with SuperMIC
	% Note: The incremental run number is replaced in the pbs script and submitted to the queue
	% D3D_RUN_NUM is the placeholder dt in the pbs script.
	elseif use_smic == 1

		% if the time step has already been computed, then contunue
		if exist('finished.txt') > 0
			disp(['Delft3D for time step: ', num2str(dt), 'has already been run.']) ;
			continue
		end

        disp(['Running Delft3D for time step: ', num2str(dt)]) ;

		fid3 = fopen('job_smic.pbs', 'rt')                     ;
		X2   = fread(fid3)                                     ;
		fclose(fid3)                                           ;

		X2   = char(X2.')                                      ;
		X2   = strrep(X2, 'D3D_RUN_NUM', D3D_run_num)          ;

		fid4 = fopen('job_smic.pbs', 'wt')                     ;
        fwrite(fid4, X2)                                       ;
		fclose(fid4)                                           ;

		[TMP1, TMP2] = system('qsub job_smic.pbs')             ;


		% This block monitors the status of the D3D run
		% When the pbs job finishes it writes "finished.txt" to the incremental D3D dir
		running = 1                                                      ;
		tic                                                              ;
		print_int = 5                                                    ;
		while running == 1
            cd(path_d3d_new)                                             ;
			
			exec_time = round(toc / 60)                                  ;
			if exec_time >= print_int && mod(exec_time, print_int) == 0

				dstr = sprintf('Delft3D run has taken (min): %3u', exec_time) ;
				disp(dstr)                                               ;

				print_int = print_int + 5                                ;
			end

			if exist('finished.txt') > 0

				dstr = sprintf('\nDelft3D run %04u has finished.\n', dt) ;
				disp(dstr)                                               ;

                running = 0                                              ;
            end

		pause(1)                                                         ;
        end
        
        T_D3D = T_D3D + toc;
    end




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% 2. Part 2: XBeach %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    d3d_nc      = [path_d3d_new, '/trih-', d3d_mdf , '.dat'];
    Fil         = qpfopen(d3d_nc);
    tmp4        = qpread(Fil,'water level', 'data', 0, [1:4]);
    tmp5        = qpread(Fil,'significant wave height','data', 0, [1]);
    Hs_offshore = nanmean(tmp5.Val(:,1));
    SE    = round(nanmean(tmp4.Val(:,1))*1000)/1000;
    SW    = round(nanmean(tmp4.Val(:,2))*1000)/1000;
    NW    = round(nanmean(tmp4.Val(:,3))*1000)/1000;
    NE    = round(nanmean(tmp4.Val(:,4))*1000)/1000;
%    offshore    = round(nanmean(tmp4.Val(:,1))*1000)/1000;
%    backshore   = round(nanmean(tmp4.Val(:,2))*1000)/1000;

    if Hs_offshore > HS_XB_threshold

        % A. Copy base
		XB_run_num  = ['XB_', num2str(dt, '%04d')]                  ;
        path_XB_new = [path_out, '/XB_' num2str(dt, '%04d')] ;
        mkdir(path_XB_new)                                   ;
        copyfile(path_XB_in, path_XB_new)                    ;

		tide_file = [path_XB_new, '/tide.txt'];
		fid       = fopen(tide_file, 'wb');
		fprintf(fid, '%f %f %f %f %f\n', 0, SE, SW, NW, NE);
		fprintf(fid, '%f %f %f %f %f\n', spinup_xb + dt_coupling, SE, SW, NW, NE);
		fclose(fid);

        % B. Copy D3D waves (only possible when known, otherwise use 'old'
        needed_sp2  = [path_d3d_new, '/barriern2t000001.sp2'] ;

		% C. convert sp2 to XBeach's CRS
		sp2_delft3d = xb_swan_read(needed_sp2)           ;
		sp2_xbeach = xb_swan_coords(sp2_delft3d, delft3d_CRS, 'geo', xbeach_CRS, 'xy');

		% D. write sp2 files 
        cd(path_XB_new);
		sp2_fnames = 'waves_';
		sp2_xbeach = xb_swan_split(sp2_xbeach, 'location');
		sp2_files = xb_swan_write(sp2_fnames, sp2_xbeach);

		% E. write loclist
		fid = fopen('loclist.txt', 'wt');
		fprintf(fid, 'LOCLIST\n');
		for iloc = 1:length(sp2_xbeach)
			sp2_fname = sp2_files{iloc};

			x = sp2_xbeach(iloc).location.data(1);
			y = sp2_xbeach(iloc).location.data(2);

			fprintf(fid, '%f\t%f\t%s\n', x, y, sp2_fname);
		end
		fclose(fid);

        % D. Change bathymetry based on previous runs
        if dt > 1
            try
                cd(path_XB_old)
                xb_x        = nc_varget('xboutput.nc', 'globalx');
                xb_y        = nc_varget('xboutput.nc', 'globaly');
                xb_z        = nc_varget('xboutput.nc', 'zb');
                xb_z        = squeeze(xb_z(end,:,:));
                cd(path_XB_new);
                save('bed.dep', 'xb_z' ,'-ascii')
            catch
            end
        end

		% log some information about XBeach step
		dstr = sprintf('Entering incremental XBeach directory:\n\t%s\n', path_XB_new) ;
		disp(dstr)                                                                    ;

		% E. Change times in params
        cd(path_XB_new)                                                               ;
        fid = fopen(['params.txt'], 'rt')                                             ;
        X   = fread(fid)                                                              ;
        fclose(fid)                                                                   ;
        X = char(X.')                                                                 ;

        % Replace morstart
        text_to_search         = 'SPINUP'                                            ;
        text_to_replace_spinup = [num2str(spinup_xb)]                                ;
        X                      = strrep(X, text_to_search, text_to_replace_spinup)   ;

        % Stop time
        text_to_search  = ['TTSTOP']                                                 ;
        text_to_replace_stop = [num2str(spinup_xb+dt_time)]                          ;
        X = strrep(X, text_to_search, text_to_replace_stop)                          ;

        % Safe new params
        fid2 = fopen(['params.txt'],'wt')                                            ;
        fwrite(fid2,X)                                                               ;
        fclose (fid2)                                                                ;
        fclose('all')                                                                ;

		% Log changes
		dstr = sprintf('params.txt was modified for timestep: %04u', dt)             ;
		disp(dstr)                                                                   ;

		dstr = sprintf('SPINUP was replaced with: %18s', text_to_replace_spinup)     ;
		disp(dstr)                                                                   ;

		dstr = sprintf('TTSTOP was replaced with: %18s\n', text_to_replace_stop)     ;
		disp(dstr)                                                                   ;




		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% F. Submit XBeach job %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% Last: Create SH file and submit to H6 (only for extreme conditions)
        if useh6 == 1
            runname         = ['LSU_X', num2str(dt, '%04d')];
            path            = path_XB_new;
            ddb_NestingToolbox_submitH6(path,'xbeach',runname,d3d_mdf, user,pass, plink,type);
            running         = 1;
            while running == 1
                cd(path_XB_new);
                if exist('finished.txt') > 0
                    running = 0;
                end
                pause(1);
            end

		% Used with SuperMIC
		% Note: The incremental run number is replaced in the pbs script and submitted to the queue
		% D3D_RUN_NUM is the placeholder dt in the pbs script.
		elseif use_smic == 1


			% if the time step has already been computed, then contunue
			if exist('finished.txt') > 0
				disp(['XBeach for time step: ', num2str(dt), 'has already been run.']) ;
				continue
			end
			
			disp(['Running XBeach for time step: ', num2str(dt)]) ;

			fid3 = fopen('job_smic.pbs', 'rt')                     ;
			X2   = fread(fid3)                                     ;
			fclose(fid3)                                           ;

			X2   = char(X2.')                                      ;
			X2   = strrep(X2, 'XB_RUN_NUM', XB_run_num)            ;

			fid4 = fopen('job_smic.pbs', 'wt')                     ;
			fwrite(fid4, X2)                                       ;
			fclose(fid4)                                           ;

			[TMP1, TMP2] = system('qsub job_smic.pbs')             ;


			% This block monitors the status of the XB run
			% When the pbs job finishes it writes "finished.txt" to the incremental XB dir
			running = 1                                                      ;
			tic                                                              ;
			print_int = 5                                                    ;
			while running == 1
				cd(path_XB_new)                                              ;
				
				exec_time = round(toc / 60)                                  ;
				if exec_time >= print_int && mod(exec_time, print_int) == 0

					dstr = sprintf('XBeach run has taken (min): %3u', exec_time) ;
					disp(dstr)                                               ;

					print_int = print_int + 5                                ;
				end

				if exist('finished.txt') > 0

					dstr = sprintf('\nXBeach run %04u has finished.\n', dt)  ;
					disp(dstr)                                               ;

					running = 0                                              ;
				end
            end
            
            T_XB = T_XB + toc;
        end
        xb_previous = 1;
    else
        xb_previous = 0;
    end
    
    % write compt times
    comp_times(dt, 1) = dt;
    comp_times(dt, 2) = T_matlab;
    comp_times(dt, 3) = T_XB;
    comp_times(dt, 4) = T_D3D;
    save(profile_table_fn, 'comp_times');
end
