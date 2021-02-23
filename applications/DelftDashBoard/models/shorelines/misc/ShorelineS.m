function [S,O]=ShorelineS(S,O,opt)
% MODEL : ShorelineS
%
% This model computes shoreline changes as a result of gradients in alongshore
% sediment transport for arbitrary shaped coastlines.
%
% INPUT:
%     S       data structure wiht fields:
%              .
%
% made by:      J.A. Roelvink (2016) - IHE Delft
% modified by:  B.J.A. Huisman (2017) - Deltares
% modified by:  A.M. Elghandour (2018- ) - IHE Delft
% modified by:  M.E. Ghonim (2019) - IHE Delft
% modified by:  J.A. Roelvink (2019) - IHE Delft
% modified by:  C.M. Mudde (2019) - TU-Delft
% modified by:  B.J.A. Huisman (2019,2020) - Deltares
% modified by:  J. Reyns (2019- ) - IHE Delft, Deltares
%
% Copyright : IHE-delft & Deltares, 2020-feb
% License   : GNU GPLv2.1
if (isoctave)
    warning('off','all');
end
switch lower(opt)
    case{'initialize'}
        S=initialize(S);
    case{'timestep'}
        [S,O]=timestep(S);
    case{'finalize'}
        S=finalize(S);
end

    function [S]=initialize(S0);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% DEFAULT INPUT PARAMETERS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        S.Hso=1;                                                                   % wave height [m]
        S.phiw0=330;                                                               % deep water wave angle in degrees [?N]
        S.spread=90;                                                               % wave spreading [?] (wave_dir from range:  S.phiw0 +/- 0.5*S.spread)
        S.WVCfile='';                                                              % wave time-series <-leave empty to use wave parameters ('S.Hso', 'S.phiw0' and 'S.spread')
        S.Waveclimfile='';                                                         % wave climate file
        S.Wavematfile='';
        S.Wavecorr=0;
        S.d=10;                                                                    % active profile height [m]
        S.ddeep=25;                                                                % Waterdepth the location of wave climate, corresponding with S.Hso [m]
        S.dnearshore=8;                                                            % Waterdepth at the 'dynamic boundary', corresponding with S.phif [m]
        S.ob=0;                                                                    % Switch for activation of observation point at which wave height will be calculated. If on, define S.dob (depth of observation point at which the local wave height and angle will be computed
        S.LDBcoastline='';                                                         % LDB with initial coastline shape ([Nx2] ASCII FILE WITHOUT HEADER) <- leave empty to use interactive mode!
        S.phif=[];                                                                 % Orientation of the foreshore [?N] (in degrees) <- only relevant for 'KAMP', 'MILH' or 'VR14'
        S.trform='CERC';                                                           % switch for transport formulation (e.g. S.trform='CERC', 'KAMP', 'MILH' or 'VR14')
        S.b=1e6;                                                                   % CERC : coeff in simple cerc formula
        S.qscal=1;                                                                 % Calibration factor of the transport (works for all transport formulas)
        S.tper=6;                                                                  % KAMP & MILH : peak wave period [s]
        S.d50=2.0e-4;                                                              % KAMP & MILH & VR14 : median grain diameter [m]
        S.porosity=0.4;                                                            % KAMP & MILH & VR14 : S.porosity (typically 0.4) [-]
        S.tanbeta=0.03;                                                            % KAMP & MILH & VR14 : mean bed slope [ratio 1/slope]
        S.rhos=2650;                                                               % KAMP & MILH & VR14 : density of sand [kg/m3]
        S.rhow=1025;                                                               % KAMP & MILH & VR14 : density of water [kg/m3]
        S.g=9.81;                                                                  % KAMP & MILH & VR14 : gravitational acceleration [m2/s]
        S.alpha=1.8;                                                               % KAMP & MILH & VR14 : calibration factor for point of breaking (S.alpha = 1.8 for Egmond data)
        S.gamma=0.72;                                                              % KAMP & MILH & VR14 : breaking coefficient (Hs/h) with 5% breaking waves
        S.Pswell=20;                                                               % VR14 : Percentage swell (between 0 - 100) [-]
        S.crit=.9;                                                                 % stability criterion (not active)
        S.Aw=5;                                                                     % factor rep. Hs/actual Hs for determining depth of closure (1.27 if time series is used, higher for a representative Hs)
        S.RWSfiletype=false;
        %% ------------------ simulation time steps & numerical--------------------
        S.tc=1;                                                                    % switch for using adaptive time step
        S.dt=0;
        % S.dt=1/365/4;                                                            % time step [year] (use 1/365/4 for time-series) (not used in combination with adaptive time step)
        %S.nt=5000;                                                                % number of timesteps (not used in combination with adaptive time step)
        S.ds0=100;                                                                 % initial space step [m]
        S.ns=100;                                                                  % number of ... (not used)
        S.reftime='2020-01-01';                                                    % Reference time (i.e. 'yyyy-mm-dd') <- leave empty to use t=0
        S.endofsimulation='2040-01-01';
        S.twopoints=1;                                                             % switch for 'S.twopoints approach'
        S.smoothfac=0;
        S.start=0;
        %% -------------------------- boundary condition -------------------------- for (non cyclic) sections (ex.straight shoreline) ,If more than one (non cyclic)sections should adjusted manually
        S.boundary_condition_start='FIXD2';                                        % boundary condition 'CTAN', 'FIXD', 'FIXD2', 'FUNC'
        S.boundary_condition_end='FIXD2';
        S.BCfile='';                                                               % Boundary condition function in time (file) , columns (time , QS_start, Qs_end)
        S.QS_start='';                                                             %[m3/year]
        S.QS_end='';
        %% ----------------------------- structures -------------------------------
        S.struct=0;                                                                % switch for using hard structures
        S.LDBstructures='';                                                        % LDB with hard structures ([Nx2] ASCII FILE WITHOUT HEADER) <- leave empty to use interactive mode!
        %% ------------------------- permeable structures -------------------------
        S.perm=0;                                                                  % switch for using hard structures
        S.LDBperm='';                                                              % LDB with perm structures ([Nx2] ASCII FILE WITHOUT HEADER) <- leave empty to use interactive mode!
        S.wavetransm=[1];                                                          % transmission factor (give array of transmission coefficients with length number of perm sections
        %% ------------------------- bypass of structures -------------------------
        S.sbypass=0;                                                               % switch for using sand bypassing around structures
        S.byp_typ=[];                                                              % use 1 to start bypassing when sand reach the structure tip , 0 to use bypassing just after the construction of the structure size== No. of structures
        S.TM=0;                                                                    % switch for using sand transmission
        S.TMF=[];                                                                  % sand transmission factor lies between  0 =< TMF =< 1, size == No. structures
        %% --------------------------- wave diffraction ---------------------------
        S.wave_diffraction=0;                                                      % wave diffraction < use 1 to avtivate
        S.WD_angle='Roelvink';                                                     % Wave diffraction approach to treat angles (Roelvink(default), Hurst)
        S.kd='Kamphuis';                                                           % Computation of kd according to Kamphuis or Roelvink analytical approx.
        S.rotfac=1.5;
        %% ---------------------------- nourishments ------------------------------
        S.nourish=0;                                                               % switch (0/1) for nourishments
        S.growth=0;                                                                % calibration of nourishment growth rate
        S.LDBnourish='';                                                           % LDB with nourishment locations ([Nx2] ASCII FILE WITHOUT HEADER) (i.e. polygon around relevant grid cells) <- leave empty to use interactive mode!
        S.nourratefile='';                                                         % nourishment rates placed in order for each nourishment polygons
        S.nourstartfile='';                                                        % nourishment start dates placed in order for each  nourishment polygons
        S.nourendfile='';                                                          % nourishment end dates placed in order for each  nourishment polygons
        S.nourrate=100;
        S.nourstart=0;
        S.nourend=[];
        %% --------------------------- Sources and Sinks --------------------------
        S.sources_sinks='';
        S.SSfile='';
        %% -------------------- aeolian transport to the dunes --------------------
        S.dune=0;                                                                  % switch for using estimate dune evolution
        S.LDBdune='';                                                              % LDB with initial Dune foot shape ([Nx2] ASCII FILE WITHOUT HEADER) <- leave empty to use interactive mode!
        S.dn=0;                                                                    % Dune Height ( measured from dune foot to dune crest)
        S.Dfelevation='';                                                          % Dune foot elevation file <-leave empty to use one value S.Dfelv along the dune system
        S.Dfelev=0;                                                                % Dune foot elevation to MSL
        S.WndCfile='';                                                             % wind time-series <-leave empty to use wave parameters ('S.uz', 'S.phiwnd0' and 'S.spread')
        S.Windclimfile='';
        S.uz='';                                                                   % wind velocity at z (m)
        S.z=10;                                                                    % elevation of measred wind data
        S.phiwnd0=330;                                                             % wind angle [?N]
        S.Watfile='';                                                              % Water levels time series relative to MSL
        S.Watclimfile='';
        S.SWL0=0;                                                                  % Fixed still water level relative to MSL
        %% ------------------- physics of spit width and channel ------------------
        S.spit_width=50;                                                           % width of tip of spit (used for overwash)
        S.spit_headwidth=200;                                                      % width of tip of spit (used for upwind correction)
        S.OWscale=0.1;                                                             % scales the rate of the overwash per timestep (i.e. what part of the deficit is moved to the backbarrier)
        S.Dsf=S.d*0.8;                                                             % underwater part of active height for shoreface -> used only in spit-width function
        S.Dbb=1*S.Dsf;                                                             % underwater part of active height for back-barrier -> used only in spit-width function
        S.Bheight=2;                                                               % berm height used for overwash funciton (i.e. added to Dsf or Dbb)
        S.tide_interaction=false;
        S.wave_interaction=false;
        S.wavefile='';                                                             % wave table (.mat)
        S.surf_width_w=250;                                                        % width of surf zone, where to collect the wave conditions from wave table
        S.surf_width=1000;                                                         % width of surf zone, where to update the bathymetry
        S.bathy_update='';                                                         % the dates when the bathymetry should be updated, the input should be in dates form, can accept more than one  {'yyyy-mm-dd'};
        %% ---------------------------------- channel ------------------------------
        S.channel=0;                                                               % switch (0/1)for migrating inlet on
        S.channel_width=550;                                                       % target channel width
        S.channel_fac=0.08;                                                         % adaptation factor
        S.LDBchannel=[];                                                           % initial channel axis
        S.flood_delta=0;                                                           % switch (0/1) for flood delta losses
        S.LDBflood=[];                                                             % wide outline of potential flood delta deposits
        S.x_flood_pol=[];
        S.y_flood_pol=[];
        S.dxf=50;                                                                  % resolution of flood delta area
        S.overdepth=2;                                                             % initial overdepth flood delta
        S.R_ero=300;                                                               % radius of flood delta influence on coast
        S.R_depo=600;                                                              % radius of inlet influence on flood delta
        S.Tscale=1;                                                                % timescale of flood delta filling
        S.xr_mc='';
        S.yr_mc='';
        %% ------------------------- formatting / output --------------------------
        S.plotvisible=1;                                                           % plot and update figure with wave conditions and modeled shoreline during run
        S.xlimits=[];                                                              % X limits of plot [m] [1x2] <- leave empty to automatically do this
        S.ylimits=[];                                                              % Y limits of plot [m] [1x2] <- leave empty to automatically do this
        S.XYwave =[];                                                              % X,Y location and scale of wave arrow [m] [1x2] (automatically determined on the basis of xy-limits and wave angle
        S.XYoffset=[0,0];                                                          % shift in X,Y locaton for plotting <- leave empty to automatically shift grid <- use [0,0] for no shift
        S.pauselength=[];                                                          % pause between subsequent timesteps (e.g. 0.0001) <- leave empty to not pause plot
        S.outputdir='Output\';                                                     % output directory
        S.rundir='Delft3D\def_model\';
        S.LDBplot = {};                                                            % cell array with at every line : string with LDB-filename, string with legend entry, string with plot format (e.g. 'b--') <- e.g. {'abc.ldb','line 1','k--'; 'def.ldb','line 2','r-.'; etc} <- leave empty to not use additional plots
        S.plotQS = 0;                                                              % plot transport rates as coloured markers along the coast
        S.llocation='SouthWest';                                                   % location of legend. Shortened for Octave compatibility
        S.usefill = 1;                                                             % switch that can be used to only plot lines instead of the fill
        S.fignryear=12;
        S.plotinterval=1;
        S.storageinterval=50;                                                      % Time interval of storage of output file ('output.mat'; [day])
        S.ld=3000;                                                                 % Width of the land fill behind the shoreline [m]
        %% -------------------------- Extract shorelines --------------------------
        S.SLplot={};
        S.extract_x_y=0;                                                           % get file with shorelines coordinates x,y
        S.print_fig=0;
        %% ---------------- Extract shoreline & dune foot locations ---------------
        S.bermw_plot=0;                                                            % For extracting  against certain times for a certain transect(s).
        S.bermw_plot_int=[];                                                       % beach berm width plot interval [Months]
        S.qplot=0;                                                                 % to plot wave and wind transport at each time step for a certain transect(s).
        S.transect='';                                                             % file indictes x-y transects to be plotted
        S.CLplot=0;                                                                % to track coastline location relative to the initial coasltime against certain time interval for a certain transect(s).
        S.CLplot_int=[];                                                           % coastline change plot interval a certain transect(s) [Months] .
        S.extract_berm_Plot=0;                                                     % to allow data extraction for berm width plotting
        %% video
        S.video=0;
        %% debug
        S.debug=0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% INITIALIZE INPUT/OUTPUT DATA
        % o        : output structure
        % oo       : output structure 2
        % vi       : input for video
        % vii      : index for output structure data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (isoctave)
            fieldnms=fieldnames(S0);
        else
            fieldnms=fields(S0);
        end
        for ii=1:length(fieldnms)
            S.(fieldnms{ii}) = S0.(fieldnms{ii});
        end
        O=struct;
        O0=struct;
        vi=struct('cdata', cell(1,1), 'colormap', cell(1,1));
        vii=0;
        if ~isempty(S.SLplot)  % For extracting specific shorelines
            plot_time(:)=datenum(S.SLplot(:,1),'yyyy-mm-dd');
            tsl=1;
            tplot=plot_time(tsl);
            plot_time(end+1)=0;
        else
            tplot=[];
            tsl=[];
            plot_time=[];
        end
        
        if ~exist(S.outputdir,'dir')
            mkdir(fullfile(pwd,S.outputdir));
        end
        
        if S.plotvisible==0
            S.plotvisible='off';
        else
            S.plotvisible='on';
        end
        
        if ~isempty(S.bathy_update)  % For bathymetry update
            update_time(:)=datenum(S.bathy_update(:,1),'yyyy-mm-dd');
            tbu=1;
            tupdate=update_time(tbu);
            update_time(end+1)=0;
        else
            tupdate=[];
            tbu=[];
            update_time=[];
        end
        
        xtip=[];
        ytip=[];
        hstip=[];
        delta0=[];
        tip_wet=[];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE COASTLINE (INITIALIZE COASTAL POINTS FROM DATA OR DRAW MANUALLY)
        %   x_mc        : [Nx1] x-positions of coastline points (islands seperated with NANs)
        %   y_mc        : [Nx1] y-positions of coastline points (islands seperated with NANs)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [x_mc,y_mc,x_mc0,y_mc0,S]=prepare_coastline(S);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE DUNE FOOT (if S.dune==1)
        % x_dune        :
        % y_dune        :
        % x_Df          :
        % y_Df          :
        % Dfelev0       :
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    [x_dune,y_dune,x_Df,y_Df,Dfelev0]=prepare_dune_foot(S);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE STRUCTURES
        % x_hard      : x-points of hard structures (multiple structures are seperated with NAN's)
        % y_hard      : y-points of hard structures (multiple structures are seperated with NAN's)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [x_hard,y_hard]=prepare_structures(S);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE PERMEABLE STRUCTURES
        % x_hard      : x-points of hard structures (multiple structures are seperated with NAN's)
        % y_hard      : y-points of hard structures (multiple structures are seperated with NAN's)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [x_perm,y_perm]=prepare_perm_structures(S);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE NOURISHMENTS
        % x_nour      : x-points of nourishments
        % y_nour      : y-points of nourishments
        % nourstart   :
        % nourend     :
        % nourrates   :
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [n_nour,x_nour,y_nour,nourstart,nourend,nourrates] = prepare_nourishment(S,x_mc,y_mc,x_hard,y_hard);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE WAVE CONDITIONS
        % WVC         : Structure with fields .Hs, .Tp, .Dir, .timenum, .x, .y (if file is specified in 'S.WVCfile')
        % WC          : Structure with fields .Hs, .Tp, .Dir (if file is specified in 'S.Waveclimfile')
        % timenum0    : model start time in timenum format based on 'S.timenum0' or 'S.reftime'
        % indw        : additional index of timepoints indw introduced by Ahmed (=time with respect to start of simulation in days) <- most likely redundant
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [WVC,WC,timenum0,indxw]=prepare_wave_conditions(S);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE WIND CONDITIONS
        % WndCF       :
        % WndCL       :
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    [WndCF,WndCL]=prepare_wind_conditions(S);   % <- new function by AE&MG
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE WATER LEVELS CONDITIONS
        % Wat_cf      :
        % Wat_cl      :
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    [Wat_cf,Wat_cl]=prepare_tide_conditions(S); % <- new function by AE&MG
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PREPARE CHANNEL
        % x_mc      :
        % y_mc      :
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if S.channel
            if ~isempty(S.xr_mc)
                xr_mc=S.xr_mc;
                yr_mc=S.yr_mc;
            elseif ~isempty(S.LDBchannel)
                xy_channel=load(S.LDBchannel);
                xr_mc=xy_channel(:,1)'-S.XYoffset(1);
                yr_mc=xy_channel(:,2)'-S.XYoffset(2);
                matname=S.LDBchannel;
                matname(end-2:end)='mat';
                if exist(matname)==2
                    load(matname);
                    n_chan=length(channels)
                    for ichan=1:n_chan
                        S.channel_width(ichan)= channels(ichan).channel_width;
                        S.channel_fac(ichan)  = channels(ichan).channel_fac;
                    end
                end
            else
                figure(11);
                axis equal;
                xl=xlim;yl=ylim;
                htxt2=text(xl(1)+0.02*diff(xl),yl(2)-0.01*diff(yl),'Add channel axis (LMB); Next channel (RMB); Exit (q)');set(htxt2,'HorizontalAlignment','Left','VerticalAlignment','Top','FontWeight','Bold','FontAngle','Italic','Color',[0.1 0.6 0.1]);
                [xr_mc,yr_mc]=select_multi_polygon('k');
                set(htxt2,'Visible','off');
                save('rivers.mat','xr_mc','yr_mc');
            end
            if S.flood_delta
                if ~isempty(S.x_flood_pol)
                    x_flood_pol=S.x_flood_pol;
                    y_flood_pol=S.y_flood_pol;
                    x_spit_pol=S.x_spit_pol;
                    y_spit_pol=S.y_spit_pol;
                elseif ~isempty(S.LDBflood)
                    xy_flood=load(S.LDBflood);
                    x_flood_pol=xy_flood(:,1)'-S.XYoffset(1);
                    y_flood_pol=xy_flood(:,2)'-S.XYoffset(2);
                    xy_spit=load(S.LDBspit);
                    x_spit_pol=xy_spit(:,1)'-S.XYoffset(1);
                    y_spit_pol=xy_spit(:,2)'-S.XYoffset(2);
                else
                    figure;plot(x_mc,y_mc,xr_mc,yr_mc,'--');axis equal;hold on;
                    disp('select flood delta outline');
                    [x_flood_pol,y_flood_pol]=select_multi_polygon('k');
                    disp('select spit outline');
                    [x_spit_pol,y_spit_pol]=select_multi_polygon('k');
                    save('flood_delta.mat','x_flood_pol','y_flood_pol','x_spit_pol','y_spit_pol');
                end
                [x_flood,y_flood,flood_deficit,fcell_area] = prepare_flood_delta ...
                    (x_flood_pol,y_flood_pol,S.dxf,S.dxf,S.overdepth);
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% INITIALIZE GRID (MAKE SURE TO DISTRIBUTE THE X/Y POINTS EQUALLY OVER COASTLINE)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % x_mc        : [Nx1] x-positions of coastline points of all coastal sections (islands seperated with NANs)
        % y_mc        : [Nx1] y-positions of coastline points of all coastal sections (islands seperated with NANs)
        % n_mc        : number of coastline sections
        % i_mc        : current index of evaluated coastline point
        [x_mc,y_mc,s_hard,sgroyne,xgroyne,ygroyne]=initialize_grid_groyne(x_mc,y_mc,S.ds0,x_hard,y_hard);
        %    [x_dune,y_dune,x_dune0,y_dune0,Dfelev]=initialize_grid_dune(S,x_mc,y_mc,x_dune,y_dune,x_Df,y_Df,Dfelev0); % <- new function by AE&MG
        n_mc=length(find(isnan(x_mc)))+1;
        xp_mc={};
        yp_mc={};
        %    [xl,yl,phirf,vi,vii,xmax,ymax,xmin,ymin,nmax,iwtw,plot_time,tsl,tplot,xp_mc,yp_mc,CLplot,CLplot2,iint,BWplot,BWplot2,innt,ds_cl,qwave,qwind,time,step,int,bermW,x_trans,y_trans,n_trans] = initialize_plot_variables(S,x_mc,y_mc,x_hard,y_hard,x_dune,y_dune,timenum0); % <- new function by AE&MG
        xp=[];yp=[];
        ngroyne=size(xgroyne,1);
        QSgroyne=zeros(1,ngroyne);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set time domain
        % tnow        : current time of simulation
        % tend        : end time of simulation
        % it  (S.nt)  : number of timesteps since start of simulation
        % itt         : number of timesteps since start of simulation
        % adt (S.dt)  : time step [yr]
        % itout       : number of output timesteps (i.e. which have been plotted / saved to file)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tnow=timenum0;
        tend=datenum(S.endofsimulation,'yyyy-mm-dd'); %HH:MM:SS
        S.tnext=tnow;  % next time for jpg output in PlotX
        %S.dt=0;
        it=-1;   % for now = -1 to follow the exisiting code
        itout=0;
        S.automatic=S.dt<=0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% CREATE FIGURE / SET LIMITS
        % xmax,ymax,xmin,ymin,nmax : initialize plotting limits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        S.mainfighandle = figure(11);clf;
        set(S.mainfighandle,'Visible',S.plotvisible);
        setFIGUREproperties(S.mainfighandle,800,600,32);
        %setFIGUREproperties(11,920,1120,32,1000,0);
        % setFIGUREproperties(11,1855,1120,32,65,0);
        xlim(S.xlimits);ylim(S.ylimits);
        xmax=0;ymax=0;xmin=0;ymin=0;nmax=0;
        
        S.x_mc=x_mc;S.y_mc=y_mc;S.x_mc0=x_mc0;S.y_mc0=y_mc0;
        S.x_hard=x_hard;S.y_hard=y_hard;S.nnour=n_nour;
        S.x_nour=x_nour;S.y_nour=y_nour; S.nourstart=nourstart;
        S.nourend=nourend;S.nourrate=nourrate;
        S.WVC=WVC;S.WC=WC;S.timenum0=timenum0;S.indxw=indxw;
        S.xr_mc=xr_mc;S.yr_mc=yr_mc;S.s_hard-s_hard;
        S.xgroyne=xgroyne;S.ygroyne=ygroyne;S.ngroyne=ngroyne;
        S.QSgroyne=QSgroyne;S.tnow=tnow;S.tend=tend;S.it=it;
        
    end  % function initialize

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [S,O]=timestep(S,O);
        x_mc=S.x_mc;y_mc=S.y_mc;x_mc0=S.x_mc0;y_mc0=S.y_mc0;
        x_hard=S.x_hard;y_hard=S.y_hard;nnour=S.n_nour;
        x_nour=S.x_nour;y_nour=S.y_nour; nourstart=S.nourstart;
        nourend=S.nourend;nourrate=S.nourrate;
        WVC=S.WVC;WC=S.WC;timenum0=S.timenum0;indxw=S.indxw;
        xr_mc=S.xr_mc;yr_mc=S.yr_mc;s_hard-s_hard;
        xgroyne=S.xgroyne;ygroyne=S.ygroyne;ngroyne=S.ngroyne;
        QSgroyne=S.QSgroyne;tnow=S.tnow;tend=S.tend;it=S.it;
        
        % while  tnow<tend
        it=it+1;
        itt=it+1;
        S.nt=it;
        QS_mc=[];
        s_mc=[];
        PHIw_mc=[];
        adt=1e6;
        %adt = S.dt;
        
        if it==0
            nmc=length(x_mc)-1;
            for ist=1:length(x_hard)
                [~,icl]=min(hypot(x_mc-x_hard(ist),y_mc-y_hard(ist)));
                im1=max(icl-1,1);
                ip1=min(icl+1,nmc+1);
                if isnan(x_mc(im1)); im1=im1-1; end
                if isnan(x_mc(ip1)); ip1=ip1+1; end
                dirm=atan2d(y_mc(ip1)-y_mc(im1),x_mc(ip1)-x_mc(im1));
                dirstr=atan2d(y_hard(ist)-y_mc(icl),x_hard(ist)-x_mc(icl));
                wetstr_mc(ist)=sind(dirstr-dirm)>0;
            end
        end
        rnd=rand;    % random number for drawing from wave climate
        if S.debug==2
            warning off
            save('debug.mat');
            warning on
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PHASE 1 : TRANSPORT                                        %%
        %% loop over coastline sections                               %%
        %% compute sediment transport                                 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i_mc=1:n_mc
            
            %% Alongshore coordinate s
            % s       : alongshore distance along the grid [m]
            % x       : x-coordinates of considered coastal section [m]
            % y       : y-coordinates of considered coastal section [m]
            % n       : number of points of considered coastal section
            % x_mc    : x-coordinate of coastline (all sections)
            % y_mc    : y-coordinate of coastline (all sections)
            % ar      : area (not computed)
            %x_mc0=x_mc;
            %y_mc0=y_mc;
            n_mc0=n_mc;
            [s,x,y,x_mc,y_mc,ar]=make_sgrid_mc(x_mc,y_mc,S.ds0,i_mc,S.smoothfac);
            n_mc=length(find(isnan(x_mc)))+1;
            S.A(itt,i_mc)=double(ar);
            n=length(x)-1;
            
            %% Introduce the wave conditions to the domain
            % Hso      : Wave height [NxM] (with N the alongshore grid cells; M the wave climate conditions at that moment in time; often N=1, M=1)
            % PHIw     : Wave direction [NxM] (with N the alongshore grid cells; M the wave climate conditions at that moment in time; often N=1, M=1)
            % tper     : Wave period [NxM] (with N the alongshore grid cells; M the wave climate conditions at that moment in time; often N=1, M=1)
            [S.Hso,S.phiw,S.tper]=introduce_wave(S,WVC,WC,tnow,x,y,rnd);
            
            %         [OP]=overwash_potential(S.tper,S.Hso,S.Bheight,S.tanbeta) % added by Ahmed
            
            %% Get refracted waves
            if S.wave_interaction
                %[ Hg,S.phiwg ] = get_interpolated_wavefield_dir_Tp( S.xg,S.yg,S.Hg,S.dirg,S.Hso,S.phiw,S.tper,S.dirtab,S.Tptab);
                [ S.xg,S.yg,S.Hg_all,S.phiwg_all,S.dirtab,S.Tptab ] = get_wave_fields_from_mat( S.wavefile );
                [S.Hg,S.phiwg,iwtw,S.phiwg_wr,S.Hg_wr]=get_interpolated_wavefield_dir_Tp(S.xg,S.yg,S.Hg_all,S.phiwg_all,S.Hso,S.phiw,S.tper,S.dirtab,S.Tptab);
                [H,S.phiw_cd]=get_refracted_waves(x,y,S.surf_width_w,S.xg,S.yg,S.Hg,S.phiwg);
                PHIw_tdp=S.phiw_cd;
                HS_tdp=H;
            elseif ~isempty(S.phif)
                % If S.phif is specified, then shoal/refract conditions to toe of
                % dynamic profile
                [kh_deep,c_deep]=GUO2002(S.tper,S.ddeep);
                [kh_tdp,c_tdp]=GUO2002(S.tper,S.dnearshore);
                n_deep = 0.5.*(1.+(2.*kh_deep)./sinh(2.*kh_deep));
                n_tdp = 0.5.*(1.+(2.*kh_tdp)./sinh(2.*kh_tdp));
                if abs(S.phiw-S.phif)<90
                    PHIw_tdp=S.phif+asind(c_tdp./c_deep.*sind(S.phiw-S.phif));
                    HS_tdp=S.Hso.*sqrt(n_deep.*c_deep.*cosd(S.phiw-S.phif)./ ...
                        (n_tdp .*c_tdp .*cosd(PHIw_tdp-S.phif)));
                else %offshore directed relative to phif
                    PHIw_tdp=S.phif+90*sign(S.phiw-S.phif);
                    HS_tdp=1.e-6;
                end
                if length(PHIw_tdp)==1
                    PHIw_tdp=repmat(PHIw_tdp,[1,n]);
                end
                if length(HS_tdp)~=n
                    HS_tdp=repmat(HS_tdp,[1,n]);
                end
                
                %disp([num2str(S.phiw,'%5.0f'),' ',num2str(S.Hso(1),'%5.2f'),' ',num2str(PHIw_tdp,'%5.0f'),' ',num2str(HS_tdp(1),' %5.2f')])
            else
                % offshore conditions used at toe of dynamic profile
                PHIw_tdp=S.phiw;
                HS_tdp=S.Hso;
                if length(S.phiw)==1
                    PHIw_tdp=repmat(S.phiw,[1,n]);
                end
                if length(S.Hso)~=n
                    HS_tdp=repmat(S.Hso,[1,n]);
                end
            end
            
            %% From here on, PHIw_tdp and HS_tdp are always given at the toe of the
            %% dynamic profile (TDP) and are always with a size of 1 by n
            
            %% Introduce permeable structures
            if S.perm>0
                HS_tdp=introduce_perm_structures(HS_tdp,PHIw_tdp,S.wavetransm,x,y,x_perm,y_perm);
            end
            %% Introduce the wind conditions to the domain
            %[PHIwnd,S]=introduce_wind(S,WndCF,WndCL,tnow); % <- new function by AE&MG
            %% Introduce water levels conditions to the domain
            %[SWL]=introduce_tide(S,Wat_cf,Wat_cl,tnow);    % <- new function by AE&MG
            
            %% Cyclic or not ?
            % cyclic     : Index describing whether the considered coastline section is cyclic
            cyclic = hypot(x(end)-x(1),y(end)-y(1))<S.ds0;
            
            %% Angles and critical angles
            [PHIc,dPHI,dPHIcrit,QSmax]=angles(S,x,y,n,PHIw_tdp,HS_tdp);
            
            %% Shadowing effect on Transport
            [xS,yS,shadowS,shadowS_h,shadow,shadowc,dPHIcor]=transport_shadow_treat(x,y,x_mc,y_mc,x_hard,y_hard,PHIw_tdp,dPHI);
            
            %% Shadowing effect on Dune Transport'
            %[shadowD,shadowD_h]=transport_shadow_dune(S,x_dune,y_dune,x_hard,y_hard,PHIw); % <- new function by AE&MG
            
            %% Wave height in the nearshore (due to refraction and shoaling)
            [HSbr,dPHIbr,hbr,cbr,nbr]=breakingheight(S.dnearshore,HS_tdp,dPHI,S.tper,S.gamma);
            
            %% Wave diffraction
            xp=[];
            yp=[];
            if ~cyclic && S.wave_diffraction==1 && ~isempty(x_hard)
                [xp,yp,HSbr,dPHIbr,xtip,ytip,hstip,delta0]=wave_diffraction_simple(x,y,S,HSbr,dPHIbr,PHIw_tdp,x_hard,y_hard,xgroyne,ygroyne,n,hbr,HS_tdp,xtip,ytip,hstip,delta0,i_mc,wetstr_mc);
            end
            
            %% Nearshore wave direction
            PHIwbr=mod(PHIc-dPHIbr,360);
            
            %% Long shore Transport
            if (strcmpi(S.trform,'CERC') || strcmpi(S.trform,'CERC2')) && S.wave_diffraction~=1
                [QS]=transport(S,dPHI,HS_tdp);QS0=QS;        % using offshore wave conditions
            else
                [QS]=transport(S,dPHIbr,HSbr,xp,yp);QS0=QS;  % using nearshore wave conditions & computing alongshore gradient in wave height in case of diffraction==1
            end
            QS(shadowS)=0;
            
            %% Upwind correction for high-angle
            % QS        : Transport rates in grid cells with upwind correction [1xN] (in [m3/yr] including pores)
            [QS,im3,ip3]=upwind_correction(dPHI,n,cyclic,S.twopoints,dPHIcrit,shadowS,shadowS_h,QSmax,QS,S.spit_headwidth,S.ds0); QS1=QS; % changed PHI to dPHIcor! (based in offshore wave condition)
            
            if S.plotQS==1
                QSplot=[QS,0];
                QSplot(QSplot==0)=nan;
            end
            
            if length(shadowS_h)>0 && S.wave_diffraction==0 % to be tested with structure case & in combination with diffraction
                QS(shadowS_h)=0;    % <- this was commented out in previous version
            end
            
            %% debugging plot for QS and SPHI
            plot_debug(S.debug,x,y,dPHI,QS,QS0,QS1); % only used when S.debug=1;
            
            %% Coastline cells intersected by hard structures
            % structS : Indices of structures on the coastline (for xy-points)
            if length(x_hard)>0   % <- Ahmed version uses 1 here
                [structS]=find_struct(x,y,x_hard,y_hard);
                structS(1)=0;structS(end)=0; % avoid problems with real groynes
                QS(structS)=0;
                %QSmax(structS)=0;
            else
                structS=[];
            end
            
            %% Sand Bypassing and Transmission
            if ~isempty(QSgroyne)
                [QSgroyne] = new_bypass(S,QS,HS_tdp,x,y,PHIc,x_hard,y_hard,s_hard,xgroyne,ygroyne,sgroyne,QSgroyne);
            end
            
            %% Dune evolution
            %[qs,qw,qss,qww]=dune_evolution(S,x_dune,y_dune,x_dune0,y_dune0,x_mc,y_mc,x_mc0,y_mc0,i_mc,Dfelev,PHIwnd,SWL,cyclic,HS_tdp,str_indx,shadowD,shadowD_h,dPHIcor); % <- new function by AE&MG
            
            %% Adaptive time step
            if ~S.automatic
                adt=S.dt;
            else
                phimax=90;
                adt=min(adt,adaptive_time_step(s,S.d,QSmax,QSmax));
            end
            
            %% Boundary condition
            [QS,S]=Boundary_condition(QS,S,cyclic,tnow,it,n,x,y,xgroyne,ygroyne);
            
            %% Collect QS, s and PHIw_tdp in QS_mc, PHIw_mc and s_mc
            if i_mc==1
                QS_mc=QS;
                s_mc=s;
                PHIw_mc=PHIw_tdp;
                HS_mc=HS_tdp;
                HSbr_mc=HSbr;
                dPHI_mc=dPHI;
                dPHIbr_mc=dPHIbr;
                PHIc_mc=PHIc;
                hbr_mc=hbr;
                PHIwbr_mc=PHIwbr;
            else
                QS_mc=[QS_mc,nan,QS];
                s_mc=[s_mc,nan,s];
                PHIw_mc=[PHIw_mc,nan,PHIw_tdp];
                HS_mc=[HS_mc,nan,HS_tdp];
                HSbr_mc=[HSbr_mc,nan,HSbr];
                dPHI_mc=[dPHI_mc,nan,dPHI];
                dPHIbr_mc=[dPHIbr_mc,nan,dPHIbr];
                PHIc_mc=[PHIc_mc,nan,PHIc];
                hbr_mc=[hbr_mc,nan,hbr];
                PHIwbr_mc=[PHIwbr_mc,nan,PHIwbr];
            end
        end
        adt_record(it+1)=adt;
        
        if S.debug==2
            warning off
            save('debug2.mat');
            warning on
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PHASE 2 : COASTLINE CHANGE                                 %%
        %% Compute coastline and dune change                          %%
        %% Merge coastline sections                                   %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x_mc1=x_mc;
        y_mc1=y_mc;
        n_mc1=n_mc;
        for i_mc=n_mc1:-1:1
            [ x,y,n_mc,i1,i2 ] = get_one_polygon( x_mc,y_mc,i_mc );
            [ s ] = get_one_polygon( s_mc,s_mc,i_mc );
            if (strcmpi(S.trform,'CERC') || strcmpi(S.trform,'CERC2'))
                [ QS,PHIw ] = get_one_polygon( QS_mc,PHIw_mc,i_mc );
            else
                [ QS,PHIw ] = get_one_polygon( QS_mc,PHIwbr_mc,i_mc );
            end
            cyclic = hypot(x(end)-x(1),y(end)-y(1))<S.ds0;
            n=length(x)-1;
            
            %% Nourisment
            % nour   : Indices of grid cells with a nourishment & number of nourishments (same length as coastline x and y)
            [nour]=get_nourishments(tnow,size(x),S.nourish,nourstart,nourend,nourrates,x,y,x_nour,y_nour,n_nour);
            
            %% Coastline change
            [x,y,S,indxw,dx,dSds,sgroyne,xgroyne,ygroyne]=coastline_change(S,s,QS,x,y,s_hard,x_hard,y_hard,sgroyne,xgroyne,ygroyne,QSgroyne,cyclic,n,tplot,tnow,tend,adt,nour,it,WVC,indxw,n_mc,i_mc,tupdate);
            
            %% Dune foot change
            %[x_dune,y_dune,S]=dune_foot_change(S,x_dune,y_dune,qss,qww,str_indx,thetaS); % <- new function by AE&MG
            
            %% check if the new grid generation did not omit some very small feature! If so, then do not evaluate further than the number of available features.
            if S.debug==1
                fprintf('it=%1.0f i_mc=%1.0f\n',it,i_mc);
            end
            if length(find(isnan(x_mc)))+1>=i_mc %& length(x)>1
                %% insert x and y back into x_mc,y_mc
                [x_mc,y_mc]=insert_section(x,y,x_mc,y_mc,i_mc);
                
                if isempty(find(isnan(x),1))
                    %% Overwash process
                    [x_mc,y_mc,x,y,spit,width] = find_spit_width_mc( i_mc,x_mc,y_mc,PHIw,S.spit_width,[x_hard],[y_hard],S.OWscale,S.Dsf,S.Dbb,S.Bheight);  % <- new function by AE&MG (located after merging of x_mc and y_mc in the code of AE and MG)
                    
                    %% Merge coastlines where necessary
                    [xnew,ynew]=merge_coastlines(x,y);
                    
                    %% insert x and y back into x_mc,y_mc
                    [x_mc,y_mc]=insert_section(xnew,ynew,x_mc,y_mc,i_mc);
                end
            end
            if i_mc==n_mc1
                dSds_mc=dSds;
            else
                dSds_mc=[dSds,nan,dSds_mc];
            end
        end
        
        %% remove spikes from small 'bubble islands'
        [x_mc,y_mc]=removespikes(x_mc,y_mc,S.ds0);
        
        %% clean up redundant NaNs
        [x_mc,y_mc,di]=cleanup_nans(x_mc,y_mc);
        
        if S.channel~=0 && ~isempty(xr_mc)
            [xr_mc,yr_mc,x_mc,y_mc,x_inlet,y_inlet] = ...
                move_channel2(xr_mc,yr_mc,x_mc,y_mc,S.ds0,S.channel_width,S.channel_fac,S.smoothfac,it);
            %             [xr_mc,yr_mc,x_mc,y_mc] = move_channel(xr_mc,yr_mc,x_mc,y_mc,S.ds0,S.channel_width,S.channel_fac,S.smoothfac,it);
            S.xr_mc=xr_mc;
            S.yr_mc=yr_mc;
        end
        
        [x_mc,y_mc]=merge_coastlines_mc(x_mc,y_mc,S.ds0);
        
        %% clean up redundant NaNs
        [x_mc,y_mc]=cleanup_nans(x_mc,y_mc);
        S.x_mc=x_mc;
        S.y_mc=y_mc;
        S.x_mc0=x_mc0;
        S.y_mc0=y_mc0;
        n_mc=length(find(isnan(x_mc)))+1;
        %S.timenum0=timenum(end);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Plotting                                                 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if S.plotQS==1
            hsc1=scatter(x,y,4,QSplot);set(hsc1,'markerFaceColor','flat');
            set(gca,'Clim',[-800000,800000]);hold on;
        end
        PHIwbr0 = [];
        HSbr0 = [];
        try
            HSbr0 = median(HSbr_mc(HSbr_mc>mean(HSbr_mc)));
            PHIwbr0 = median(PHIwbr_mc(HSbr_mc>mean(HSbr_mc)));
            %dPHIbr0 = S.phif-median(dPHIbr(~isnan(dPHIbr)));
        end
        [vi,xp_mc,yp_mc,S,xmax,ymax,xmin,ymin,nmax,tsl,tplot,vii]=PlotX(S,x_hard,y_hard,x_mc0,y_mc0,it,x_mc,y_mc,S.ld,tnow,S.phiw,tplot,tsl,plot_time,xmax,ymax,xmin,ymin,nmax,xp_mc,yp_mc,vi,vii,PHIw_mc,HSbr0,PHIwbr0);
        if S.dune && S.qplot
            %            [qwave,qwind,innt,time,step]=Plot_qrates_wave_wind(S,x_dune,y_dune,x_trans,y_trans,n_trans,qss,qww,innt,tnow,qwave,qwind,time,step);   % <- new function by AE&MG
        end
        if S.dune && S.bermw_plot
            %            [BWplot, bermW,int,BWplot2]=Plot_berm_width(S,x_mc,y_mc,x_dune,y_dune,xl,yl,n_trans,BWplot,BWplot2,bermW,tnow,int,x_trans,y_trans);    % <- new function by AE&MG
        end
        if S.CLplot
            %            [CLplot,int,CLplot2,ds_cl]=plot_coastline_transect(S,x_mc,y_mc,x_mc0,y_mc0,n_trans,CLplot,CLplot2,tnow,iint,x_trans,y_trans,ds_cl);    % <- new function by AE&MG
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Apply shoreline change due to tide                       %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if S.tide_interaction
            [S]=update_shoreline(S);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Store data in OUTPUT.MAT                                 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% store shorelines data in structure (information before coastline update)
        if (tnow-timenum0)>=itout*S.storageinterval
            [O]=save_shorelines(O,it,S.dt,S.tc,S.nt,tnow,...             % time parameters
                x_mc,y_mc,dSds_mc,...                    % x,y (after coastline update) and coastline change
                x_mc1,y_mc1,PHIc_mc,QS_mc,...            % x,y (before coastline update) and corresponding QS
                S.Hso,S.phiw,S.tper,S.phif,...           % offshore waves
                HS_mc,PHIw_mc,dPHI_mc,...                % nearshore waves at depth-of-closure
                HSbr_mc,PHIwbr_mc,dPHIbr_mc,hbr_mc,...   % waves at point of breaking
                x_hard,y_hard,...                        % structures
                x_nour,y_nour);                          % nourishment locations
        end
        
        %% store all shoreline data
        if (tnow-timenum0)>=itout*S.storageinterval
            warning off
            save(fullfile(pwd,S.outputdir,'output.mat'),'O','S');
            warning on
            itout=itout+1;
        end
        
        %% bathymetry update
        if ~isempty(S.bathy_update)&& S.dt==(tupdate-tnow)/365
            [S]=update_bathy(S,it);
            % %  reproduce wave table
            S.wavefile=strcat('Wave_table',num2str(it));
            [S]=waverefrac_implicit(S);
            close(figure(1));
            close(figure(2));
            tbu=tbu+1;
            tupdate=update_time(tbu);
        end
        tnow = tnow + S.dt*365; %S.dt*365; %dt [year]   %calculate the current time after each time step
        S.times(it+1)=tnow;
        fprintf('%s \n',datestr(tnow,'yyyy-mm-dd HH:MM'));
        %end
        
        S.x_mc=x_mc;S.y_mc=y_mc;S.x_mc0=x_mc0;S.y_mc0=y_mc0;
        S.x_hard=x_hard;S.y_hard=y_hard;S.nnour=n_nour;
        S.x_nour=x_nour;S.y_nour=y_nour; S.nourstart=nourstart;
        S.nourend=nourend;S.nourrate=nourrate;
        S.WVC=WVC;S.WC=WC;S.timenum0=timenum0;S.indxw=indxw;
        S.xr_mc=xr_mc;S.yr_mc=yr_mc;S.s_hard-s_hard;
        S.xgroyne=xgroyne;S.ygroyne=ygroyne;S.ngroyne=ngroyne;
        S.QSgroyne=QSgroyne;S.tnow=tnow;S.tend=tend;S.it=it;
        
    end % function timestep

    function [S,O]=finalize(S,O);
        %% Extract shorelines cooridnates /figures at specific dates
        extract_shoreline(S,x_hard,y_hard,x_mc0,y_mc0,xp_mc,yp_mc);
        
        %% for Plot beach berm witdh variation against time
        %   extract_for_berm_plotting(S,step,qwind,qwave,time,bermW,WBplot2,ds_cl,CSplot2,n_trans);
        
        %% videos
        if S.video==1
            make_video(S,vi);
        end
        % Area_BSS_check(S)
    end