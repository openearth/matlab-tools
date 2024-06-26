%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19050 $
%$Date: 2023-07-14 09:55:51 +0200 (Fri, 14 Jul 2023) $
%$Author: chavarri $
%$Id: adapt_input_01_layout.m 19050 2023-07-14 07:55:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/adapt_input_01_layout.m $
%
%Creates `simdef` simulation definition structure based on a reference input `simdef`
%given as a function `F_input_D3D`, the variation variables from a matrix of 
%variation `input_m_s`, and a function to adapt the input `F_adapt`.

function simdef=D3D_adapt_input(input_m_s,F_adapt,F_input_D3D)

%% read reference

simdef.dummy=NaN;
simdef=F_input_D3D(simdef); %reference

%% adapt simdef based on the modifying function

simdef=F_adapt(simdef,input_m_s);

%% adapt simdef based on input_m_s

simdef=D3D_modify_structure(simdef,input_m_s);

%% time

c=simdef.ini.u+sqrt(simdef.mdf.g*simdef.ini.h);
dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step

dt_opt=dt_opt/1;

[simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,simdef.mdf.Tstop,simdef.mor.MorStt,simdef.mor.MorFac,simdef.mdf.Tstop/simdef.mdf.Flmap_dt);


end %function
