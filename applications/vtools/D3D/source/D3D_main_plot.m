%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(oetsettings)
%add paths to RIV tools:
%   https://repos.deltares.nl/repos/RIVmodels/rivtools/trunk/matlab
%   run(rivsettings)

%% PREAMBLE
clear
% close all

%% INPUT

    %% debug
    
flg.profile=0;

    %% path
%form of input
    %1=several simulations in structured folders; 
    %2=one simulation;
    %3=from script
def.sim_in=2; 
    %1) (for more than one simulation, structured results)
% def.simulations={'051','043','057','061'}; %simulations to run the loop
% def.series={'P','P','P','P'}; %series to analyze
% def.paths_runs='n:\My Documents\runs\D3D\';
    %2) (for 1 unstructured simulation)
% def.folder='C:\Users\chavarri\temporal\09_gsd_preparation\gsd_014\dflowfm\';
% def.folder='C:\Users\chavarri\temporal\D3D\runs\AC\001\';
% def.folder='C:\Users\chavarri\temporal\200522_debug_vowA\r_003\';
% def.folder='C:\Users\chavarri\temporal\10_constant_discharge\ctq_001\dflowfm\';
% def.folder='p:\11203223-tki-rivers\02_rijntakken_2020\04_runs\08_morpho_1\mr1_070\dflowfm';
% def.folder='p:\11203223-tki-rivers\02_rijntakken_2020\04_runs\15_morpho_j11\straight_morpho_1995_2011\dflowfm\';
def.folder='C:\Users\chavarri\temporal\200930_bendeffect\r002\dflowfm\';
% def.folder='p:\11205272_waterverd_verzilting_2020\006_Vaardiepte_voorspellen\02_Modelresultaten\DIMR\realization_1\dflow1d\';
% def.folder='p:\11204644-evaluatie-langsdammen\wp10_beheer_onderhoud_kosten\04_sm\01_runs\r_001\';
% def.folder='c:\Users\chavarri\temporal\D3D\runs\V\080\dflowfm\';
    %3) (from script)
% def.script='input_plot_FM_3Dflow_validation_u';
% def.script='input_plot_groynes_lab_groyne_field';

simdef.file.checkouts='c:\Users\chavarri\checkouts\openearthtools_matlab\oetsettings.m';

    %% variable
simdef.flg.which_p=3; %which kind of plot: 
%MAP
%      LOOP ON TIME
%   1=3D bed elevation and gsd
%   2=2DH
%   3=1D
%   4=patch
%   9=2DV
%  10=cross-sections
%       OTHER
%   5=xtz
%   6=xz for several time

%   7=0D
%   8=2DH cumulative
%HIS
%      LOOP ON TIME
%   a=vertical profile
%      OTHER
%   b=for a given time vector
%
%GRID
%   grid
%
simdef.flg.which_v=8; %which variable: 
%   1=etab
%   2=h
%   3=dm Fak
%   4=dm fIk
%   5=fIk
%   6=I
%   7=elliptic
%	8=Fak
%   9=detrended etab based on etab_0
%   10=depth averaged velocity
%   11=velocity
%   12=water level
%   13=face indices
%   14=active layer thickness
%   15=bed shear stress
%   16=specific water discharge
%   17=cumulative bed elevation
%   18=water discharge 
%   19=bed load transport in streamwise direction (at nodes)
%   20=velocity at the main channel
%   21=discharge at main channel
%   22=cumulative nourished volume of sediment
%   23=suspended transport in streamwise direction
%   24=cumulative bed load transport
%   25=total sediment mass (summation of all substrate layers)
%   26=dg Fak
%   27=total sediment thickness (summation of all substrate layers)
%   28=main channel averaged bed level
%   29=sediment transport magnitude at edges m^2/s
%   30=sediment transport magnitude at edges m^3/s
%   31=morphodynamic width [m]
%   32=Chezy 
%   33=cell area [m^2]

simdef.flg.which_s=4; %which plot style: 
%   1=surf
%   2=contourf
%   3=scatter
%   4=patch
%   5=text

    %% domain
    
% def.rsl_mn=[26044]; %NaN plots all, a number plots that face only
% def.rsl_mn=NaN; %NaN plots all, a number plots that face only

% def.branch={'channel1','channel2'}; 
% def.branch={'Channel1','Channel2'}; 
% def.branch={'Channel1'}; 
% def.branch={'1','2','3','4','5'}; 
% def.branch={'Channel_1D_1'}; 
% def.branch={'BovenEijsden','Kalkmaas1','Kalkmaas2','Kalkmaas3','Kalkmaas4','Grensmaas1','Grensmaas2','Grensmaas3','Grensmaas4','Grensmaas5','Grensmaas6','Zandmaas01','Zandmaas02','Zandmaas03','Zandmaas04','Zandmaas05','Zandmaas06','Zandmaas07','Zandmaas08','Zandmaas09','Zandmaas10','Zandmaas11','Zandmaas12','Zandmaas13','Zandmaas14','Zandmaas15','Zandmaas16','Zandmaas17','Getijmaas1','Getijmaas2','Getijmaas3','Getijmaas4','BergscheMaas1','BergscheMaas2'}; 
% def.branch={'01_SAZ','02_SAZ','03_SAZ','04_SAZ','05_SAZ','06_SAZ','07_SAZ','08_SAZ','09_SAZ','10_SAZ','11_SAZ','01_SAZ','13_SAZ_A','13_SAZ_B_A','13_SAZ_B_B_A','13_SAZ_B_B_B_A','13_SAZ_B_B_B_B','14_SAZ','15_SAZ','16_SAZ_A','16_SAZ_B'}; 
def.branch={'29_A','29_B_A','29_B_B','29_B_C','29_B_D','52_A','52_B','31_A_A','31_A_B','31_A_C','31_B','51_A','BovenLobith','Bovenrijn'};
% def.branch={'Nederrijn1','Nederrijn2','Nederrijn3','Nederrijn4','Nederrijn5','Nederrijn6','Lek1','Lek2','Lek4','Lek5','Lek6','Lek7','Lek8'};
% def.branch={'Waal1','Waal2','Waal3','Waal4','Waal5','Waal6'}; %RT+G Waal;
% def.branch={'PanKan1','PanKan2'}; 
% def.branch={'IJssel01','IJssel02','IJssel03','IJssel04','IJssel05','IJssel06','IJssel07','IJssel08','IJssel09','IJssel10','IJssel11','IJssel12'}; 
% def.branch={'Kattendiep2'}; 
% def.branch={'Lek1'}; 
% def.branch={'Nederrijn1','Nederrijn2'}; 
% def.branch={'Waal1'}; 
% def.branch={'BovenLobith','Bovenrijn'};

% def.station=3; %station number (for history files)
% def.station={'Pannerdenschekop'}; %station number (for history files)
% def.station={'867.00_BR'}; %station number (for history files)
% def.station={'868.00_WA'}; %station number (for history files)
% def.station={'868.00_PK'}; %station number (for history files)
% def.station={'825_Rhein'}; %station number (for history files)
% def.station={'Q-DrielbovDrielben'}; %station number (for history files)
% def.station={'LMW Drielboven'}; %station number (for history files)
% def.station={'LMW Drielbeneden'}; %station number (for history files)
% def.station={'LMW IJsselkop'}; %station number (for history files)
% def.station={'LMW Lobith'}; %station number (for history files)
% def.station={'obsCross_Pannerdenschekop_PK'};
% def.station={'obsCross_Pannerdenschekop'};
% def.station={'obsCross_900.00_WA'};
% def.station={'868.00_WA'};
% def.station={'obsCross_878.00_PK'};

%x,y,f coordinate if NaN, all
% def.rsl_x=NaN;
% def.rsl_y=NaN;
% def.rsl_f=1:8;
% def.rsl_f=14:17;
% def.rsl_f=13:16;
% def.rsl_f=9:12;
% def.pol.x=linspace(0,30000,1000); %polyline with x coordinates to make cross section (FM)
% def.pol.y=linspace(50,50,1000); %polyline with y coordinates to make cross section (FM)

% def.kcs=[17,1]; %cross-sections to plot [first one, counter]

%D3D4
% in_read.kx=NaN;
% in_read.ky=NaN;

    %% times to plot
    
    %0=all the time steps; 
    %1='time' is a single time or a vector with the time steps to plot. If NaN it plots the last time step; 
    %2='time' is the spacing between 1 and the last results;
def.rsl_input=1; 
def.rsl_time=1;

    %% print
simdef.flg.print=0; %NaN=nothing; 0=pause until click; 0.5=pause 'pauset' time; 1=eps; 2=png
simdef.flg.pauset=0.1;
simdef.flg.save_name=NaN; %name to save a figure, if NaN it gives automatic name

simdef.flg.elliptic=0; %plot elliptic results: 0=NO; 1=YES (from ect); 2=YES (from D3D)

simdef.flg.plot_unitx=1; %conversion from m
simdef.flg.plot_unity=1; %conversion from m
simdef.flg.plot_unitz=1; %conversion from m
% simdef.flg.plot_unitt=1; %conversion from s
% simdef.flg.plot_unitt=1/3600; %conversion from s
simdef.flg.plot_unitt=1/3600/24; %conversion from s
% simdef.flg.plot_unitt=1/3600/24/365; %conversion from s

%plot limits (comment to make it automatic)
% simdef.flg.lims.x=[5.5,7.5]*1e4; %x limit in [m]
% simdef.flg.lims.y=[0,20]; %y limit in [m]
% simdef.flg.lims.z=[0,1]; %z limit in [m] (for 1D it is the limit of the vertical axis)
% simdef.flg.lims.f=[-0.01,0.01]; %variable limits [default units]
% simdef.flg.view=[56.5545   80.7235];
% simdef.flg.prnt_size=[0,0,18.2,14]; %slide=[0,0,25.4,19.05]; 

% simdef.flg.marg.mt=2.5; %top margin [cm]
% simdef.flg.marg.mb=1.5; %bottom margin [cm]
% simdef.flg.marg.mr=2.5; %right margin [cm]
% simdef.flg.marg.ml=2.0; %left margin [cm]
% simdef.flg.marg.sh=1.0; %horizontal spacing [cm]
% simdef.flg.marg.sv=0.0; %vertical spacing [cm]

simdef.flg.equal_axis=0; %equal axis

simdef.flg.prop.fs=12; %font size [points]
simdef.flg.prop.edgecolor='none'; %edge color in surf plot

simdef.flg.cbar.displacement=[0.0,0.0,0,0.00]; 
simdef.flg.ncmap=100; %number of colors to discretize the colormap

simdef.flg.addtitle=1; %add title to the plot

simdef.flg.zerosarenan=0; %convert 0 in coordinate to NaN
simdef.flg.nine3sarenan=0; %convert 999 in variable to NaN

simdef.flg.interp_u=1;

%save data
simdef.flg.save_data=0; %0=NO, 1=xyz

%figure with face indices
simdef.flg.fig_faceindices=0; %0=NO, 1=YES

%not necessary
simdef.D3D_home=NaN;

simdef.flg.mean_type=2; %1=log2; 2=mean

%% conversion to river kilometers
% % in_read.path_rkm="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rkm_rijntakken_rhein.csv";
% in_read.rkm_curved="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rijn-flow-model_map_curved.nc";
% in_read.rkm_TolMinDist=300; %tolerance for accepting an rkm point

%%
%% CALL
%%

if flg.profile
    profile off
    profile on
end

if def.sim_in==3
    run(def.script)
end

%number of simulations to analyze
switch def.sim_in
    case 1
        ns=numel(def.simulations); 
    case 2
        ns=1;
    case 3
%         ns=numel(def_folder);
          ns=numel(allinput);
end

%% loop on simulations
for ks=1:ns
% ks=1
       
    if def.sim_in==3
%         script2in
        v2struct(allinput(ks));
    end %flg.sim_in
    
    %computer paths
    switch def.sim_in
        case 1
            if isfield(simdef,'D3D') && isfield(simdef.D3D,'dire_sim')
                D3D=rmfield(simdef.D3D,'dire_sim');
                simdef.D3D=D3D;
            end
            simdef.runid.number=def.simulations{ks};
            simdef.runid.serie=def.series{ks};
            simdef.D3D.paths_runs=def.paths_runs;
        case {2,3}
            aux.strspl=strsplit(def.folder,'\');
            simdef.runid.number=str2double(aux.strspl{end-1});
            simdef.runid.serie=aux.strspl{end-2};
            simdef.D3D.dire_sim=def.folder;
    end %flg.sim_in
    simdef=D3D_comp(simdef);
    
    %simulation paths
    simdef=D3D_simpath(simdef);
    
    %create figures folder (if it does not exist yet)
    if exist(fullfile(simdef.D3D.dire_sim,'figures'),'dir')==0
       mkdir(simdef.D3D.dire_sim,'figures')
    end
    
    %% PLOT GRID
    if strcmp(simdef.flg.which_p,'grid')
        out_read=D3D_read(simdef,NaN);
        D3D_figure_domain(simdef,out_read);
    else
        
    %load simdef
%     load(fullfile(file.dire_sim,'simdef.mat'));
    
    %dimensions
    in_read.kt=0; %give as output the domain size
    out_read=D3D_read(simdef,in_read);
    
    %create results time vector
    nTt=out_read.nTt; %number of map time results
    if ~ischar(simdef.flg.which_p)
        switch def.rsl_input
            case 0
                aux.rsl_v=1:1:nTt; %old
    %             aux.rsl_v=[1,nTt]; %new NO!!
            case 1
                if isnan(def.rsl_time)
                    aux.rsl_v=nTt;
                else
                    aux.rsl_v=def.rsl_time;
                end
            case 2
                aux.rsl_v=1:def.rsl_time:nTt;
        end
    else
        switch def.rsl_input
            case 0
%                 aux.rsl_v=1:1:nTt; %old
                aux.rsl_v=[1,Inf]; %new NO!!
            case 1
                error('ups')
%                 if isnan(def.rsl_time)
%                     aux.rsl_v=nTt;
%                 else
%                     aux.rsl_v=def.rsl_time;
%                 end
            case 2
                error('ups')
%                 aux.rsl_v=1:def.rsl_time:nTt;
        end
    end
    
    if isfield(def,'pol')
        in_read.pol.x=def.pol.x;
        in_read.pol.y=def.pol.y;
    end
     
    %define cross-sections to plot
    if isfield(def,'kcs')
        in_read.kcs=def.kcs;
    end
    
    %define f nodes to plot
    if isfield(def,'rsl_f')
        in_read.kf=def.rsl_f;
    end
    
    %define station to read
    if isfield(def,'station')
        in_read.station=def.station;
    end
        
%     %define dump areas to read
%     if isfield(def,'dump_area')
%        in_read.dump_area=def.dump_area;
%     end

%     %define dump areas to read
%     if isfield(def,'crs')
%        in_read.crs=def.crs;
%     end
    
    %branches
    if isfield(def,'branch')
        in_read.branch=def.branch;
    end
    
    %load elliptic
    if simdef.flg.elliptic==1
        load(fullfile(simdef.D3D.dire_sim,'ect','eigen_ell_p'));
    end
    
    %% MAP
    if isa(simdef.flg.which_p,'double')
    if def.rsl_input==0 && isnan(simdef.flg.print) 
        error('You want to plot all time steps but do nothing with the plot. That is nonsense')
    end
    switch simdef.flg.which_p
        case {1,2,3,4,9,10}
        %% loop on time
            for kt=aux.rsl_v
%                 in_read.kt=kt; %old
                in_read.kt=[kt,1]; %new 
                out_read=D3D_read(simdef,in_read);
                if simdef.flg.save_data
                    D3D_save(simdef,out_read)
                end
                switch simdef.flg.which_p
                    case 1 % 3D of bed elevation and gs
                        if simdef.D3D.structure==1
                            D3D_figure_3D(simdef,out_read);   
                        else
                            D3D_figure_3D_u(simdef,out_read);   
                        end
                    case 2 % 2DH
                        if simdef.D3D.structure==1
                            D3D_figure_2D(simdef,out_read); 
                        else
                            D3D_figure_2D_u(simdef,out_read); 
                        end
                        %kml
                        
                        %
                    case 3 % 1D
                        if simdef.D3D.structure==1
                            D3D_figure_1D(simdef,out_read);   
                        else
                            D3D_figure_1D_u(simdef,out_read);  
                        end
                    case 4 % patch
                        D3D_figure_patch(simdef,out_read); 
                    case 9
%                         if simdef.D3D.structure==1
%                         else    
%                             D3D_figure_2DV_u(simdef,out_read);
%                             D3D_figure_2DV_x_u(simdef,out_read);
%                             D3D_figure_2DV_y_u(simdef,out_read);
                            D3D_figure_2DV_z_u(simdef,out_read);
%                             D3D_figure_2DV_yz_u(simdef,out_read);
%                         end
                    case 10 %cross-sections
                        D3D_figure_crosssection(simdef,out_read);

                end
                        %display
                aux.strdisp=sprintf('kt=%d %4.2f %%',kt,kt/aux.rsl_v(end)*100);
                disp(aux.strdisp)
            end %kt
        case 5
        %% xtz
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_xt2(simdef,simdef,out_read); 
        %% xz
        case 6
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_xz(simdef,simdef,out_read); 
        %% 0D
        case 7
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
        %% 2DH cumulative in time
        case 8
            in_read.kt=aux.rsl_v; 
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_2D(simdef,simdef,out_read); 
        otherwise
                error('mmm')
    end
    %% HIS
    else
    switch simdef.flg.which_p
        case {'a'}
        %% loop on time
            for kt=aux.rsl_v
                in_read.kt=kt; 
                out_read=D3D_read(simdef,in_read);
                switch simdef.flg.which_p
                    case {'a'}
                        D3D_figure_his_verticalprofile(simdef,out_read); 
                end %which_p (2)
            end %kt
        %% other
        case {'b'}
            in_read.kt=aux.rsl_v; 
            out_read=D3D_read(simdef,in_read);
            D3D_figure_his(simdef,out_read); 
    end %loop on time
    end %his
    end %grid

        
end %ks

%%

if flg.profile
    profile off
    profile viewer
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                