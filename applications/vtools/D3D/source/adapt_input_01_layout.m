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

% simdef=D3D_modify_structure(simdef,input_m_s);
fn=fieldnames(input_m_s);
nf=numel(fn);
for kf=1:nf
    tok=regexp(fn{kf},'__','split');
    if isempty(tok); continue; end
    if strcmp(tok{1,1},fn{kf}); continue; end %there is no '__'
%     if ~isfield(simdef,tok{1,1}); continue; end
%     if ~isfield(simdef.(tok{1,1}),tok{1,2}); continue; end
    simdef.(tok{1,1}).(tok{1,2})=input_m_s.(fn{kf});
end

%% time

c=simdef.ini.u+sqrt(simdef.mdf.g*simdef.ini.h);
dt_opt=simdef.mdf.CFL*simdef.grd.dx/c; %optimum time step

dt_opt=dt_opt/1;

[simdef.mdf.Dt,simdef.mdf.Tstop,simdef.mdf.Flmap_dt,simdef.mor.MorStt]=D3D_adapt_time(dt_opt,simdef.mdf.Tstop,simdef.mor.MorStt,simdef.mor.MorFac,simdef.mdf.Tstop/simdef.mdf.Flmap_dt);


end %function
