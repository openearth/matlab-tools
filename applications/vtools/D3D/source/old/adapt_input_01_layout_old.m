%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Description

function simdef=adapt_input_01(input_m_s)

%% read reference

simdef.dummy=NaN;
simdef=input_D3D(simdef); %reference

%% adapt simdef based on input_m_s

simdef=D3D_modify_structure(simdef,input_m_s);

%% time

c=simdef.ini.u+sqrt(simdef.mdf.g*simdef.ini.h);
dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step

dt_opt=dt_opt/1;

[simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,simdef.mdf.Tstop,simdef.mor.MorStt,simdef.mor.MorFac,simdef.mdf.Tstop/simdef.mdf.Flmap_dt);


end %function
