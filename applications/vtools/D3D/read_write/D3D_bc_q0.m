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

function D3D_bc_q0(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

file_name=simdef.file.bc_q0;
% dire_sim=simdef.D3D.dire_sim;
fname_pli_u=simdef.pli.fname_u;
time=simdef.bct.time_Q;
Q=simdef.bct.Q;

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

upstream_nodes=simdef.mor.upstream_nodes;

%other
nt=length(time);

%% OPEN

[fid,fname_local]=write_local_and_copy('open',file_name,'overwrite',~check_existing);

%% WRITE

for kun=1:upstream_nodes
    fprintf(fid,'[forcing]\r\n');
    fprintf(fid,'Name                            = %s_%02d_0001\r\n',fname_pli_u,kun);
    fprintf(fid,'Function                        = timeseries\r\n');
    fprintf(fid,'Time-interpolation              = linear\r\n');
    fprintf(fid,'Quantity                        = time\r\n');
    fprintf(fid,'Unit                            = seconds since 2000-01-01 00:00:00\r\n');
    fprintf(fid,'Quantity                        = dischargebnd\r\n');
    fprintf(fid,'Unit                            = m3/s\r\n');
    for kt=1:nt
        fprintf(fid,'%0.7E \t%0.7E \r\n',time(kt)*Tfact,Q(kt)/upstream_nodes);
    end
    fprintf(fid,'\r\n');
    fprintf(fid,'[forcing]\r\n');
    fprintf(fid,'Name                            = %s_%02d_0002\r\n',fname_pli_u,kun);
    fprintf(fid,'Function                        = timeseries\r\n');
    fprintf(fid,'Time-interpolation              = linear\r\n');
    fprintf(fid,'Quantity                        = time\r\n');
    fprintf(fid,'Unit                            = seconds since 2000-01-01 00:00:00\r\n');
    fprintf(fid,'Quantity                        = dischargebnd\r\n');
    fprintf(fid,'Unit                            = m3/s\r\n');
    for kt=1:nt
        fprintf(fid,'%0.7E \t%0.7E \r\n',time(kt)*Tfact,Q(kt)/upstream_nodes);
    end
    fprintf(fid,'\r\n');
end %knu

%% CLOSE

write_local_and_copy('close',fid,fname_local,file_name)

end %function