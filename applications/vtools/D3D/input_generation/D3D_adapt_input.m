%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Creates `simdef` simulation definition structure based on a reference input `simdef`
%given as a function `F_input_D3D`, the variation variables from a matrix of 
%variation `input_m_s`, and a function to adapt the input `F_adapt`.

function simdef=D3D_adapt_input(input_m_s,F_adapt,F_input_D3D)

%% read reference

simdef.dummy=NaN;
simdef=F_input_D3D(simdef); %reference

%% adapt simdef based on input_m_s

simdef=D3D_modify_structure(simdef,input_m_s);

%% adapt simdef based on the modifying function

simdef=F_adapt(simdef,input_m_s);

%% time

c=simdef.ini.u+sqrt(simdef.mdf.g*simdef.ini.h);
dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step

dt_opt=dt_opt/1;

[simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,simdef.mdf.Tstop,simdef.mor.MorStt,simdef.mor.MorFac,simdef.mdf.Tstop/simdef.mdf.Flmap_dt);


end %function
