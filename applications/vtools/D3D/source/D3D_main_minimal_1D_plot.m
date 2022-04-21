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
clc

%% INPUT

in_read.branch={'Rhine','Waal'}; %branch
in_read.kt=10; %output time index
simdef.D3D.dire_sim='C:\Users\chavarri\temporal\220421_JL\r012\dflowfm\';
simdef.flg.which_v=2; 
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

%% do not change

simdef.flg.which_p=3; %plot type 

%% CALL

simdef=D3D_comp(simdef);
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);

%% PLOT

figure
plot(out_read.SZ,out_read.z)
ylabel(out_read.zlabel)
xlabel('streamwise coordinate [m]')
title(sprintf('time = %f s',out_read.time_r))

