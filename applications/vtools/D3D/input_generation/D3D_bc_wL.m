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
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bc_wL(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

time=simdef.bct.time;
etaw=simdef.bct.etaw;

% Tunit=simdef.mdf.Tunit;
% Tfact=simdef.mdf.Tfact;
Tfact=1; %only for s
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;

%round time
if time(end)<Tstop
    time(end)=(floor(Tstop/Dt)+1)*Dt;
    warning('The end time in bct is smaller than the end time of the simulation (maybe due to rounding issues). I have changed it.')
end

%other
nt=length(time);

%% FILE

%no edit
kl=1;
data{kl, 1}='[forcing]'; kl=kl+1;
data{kl, 1}='Name                            = Downstream_0001'; kl=kl+1;
data{kl, 1}='Function                        = timeseries'; kl=kl+1;
data{kl, 1}='Time-interpolation              = linear'; kl=kl+1;
data{kl, 1}='Quantity                        = time'; kl=kl+1;
data{kl, 1}='Unit                            = seconds since 2000-01-01 00:00:00'; kl=kl+1;
data{kl, 1}='Quantity                        = waterlevelbnd'; kl=kl+1;
data{kl, 1}='Unit                            = m'; kl=kl+1;
for kt=1:nt
data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,etaw(kt)); kl=kl+1;
end
data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[forcing]'; kl=kl+1;
data{kl, 1}='Name                            = Downstream_0002'; kl=kl+1;
data{kl, 1}='Function                        = timeseries'; kl=kl+1;
data{kl, 1}='Time-interpolation              = linear'; kl=kl+1;
data{kl, 1}='Quantity                        = time'; kl=kl+1;
data{kl, 1}='Unit                            = seconds since 2000-01-01 00:00:00'; kl=kl+1;
data{kl, 1}='Quantity                        = waterlevelbnd'; kl=kl+1;
data{kl, 1}='Unit                            = m'; kl=kl+1;
for kt=1:nt
data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,etaw(kt)); kl=kl+1;
end

%% WRITE

file_name=fullfile(dire_sim,'bc_wL.bc');
writetxt(file_name,data)

