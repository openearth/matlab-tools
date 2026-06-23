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
%bcm file creation

%INPUT:
%   -
%
%OUTPUT:
%   -


function D3D_bcm_u(simdef,varargin)
%% RENAME

tim=simdef.bcm.time;
Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
IBedCond=simdef.mor.IBedCond;
nt=numel(tim);
upstream_nodes=simdef.mor.upstream_nodes;

%I change the sign of 3 in structured, so in all cases it is 7
if IBedCond==3
    IBedCond=7;
end
    
switch IBedCond
    case 2
        eta=-simdef.bcm.eta;
    case 5
        transport=simdef.bcm.transport;
        nf=size(transport,2);
    case 7
        deta_dt=simdef.bcm.deta_dt;
end

%% OPEN

[fid,fname_local]=write_local_and_copy('open',simdef.file.bcm,'overwrite',true);

%% WRITE

for kun=1:upstream_nodes
    fprintf(fid,'table-name          ''Boundary Section : %d''\r\n',kun);
    fprintf(fid,'contents            ''Uniform''\r\n');
    fprintf(fid,'location            ''Upstream_%02d''\r\n',kun);
    fprintf(fid,'time-function       ''non-equidistant''\r\n');
    fprintf(fid,'reference-time       20000101\r\n');
    switch Tunit
        case 'S'
            fprintf(fid,'time-unit           ''seconds''\r\n');
        case 'M'
            fprintf(fid,'time-unit           ''minutes''\r\n');
    end
    fprintf(fid,'interpolation       ''linear''\r\n');
    switch Tunit
        case 'S'
            fprintf(fid,'parameter           ''time'' unit ''[sec]''\r\n');
        case 'M'
            fprintf(fid,'parameter           ''time'' unit ''[min]''\r\n');
    end
    
    switch IBedCond
        case 2
            fprintf(fid,'parameter           ''depth'' unit ''[m]''\r\n');
            fprintf(fid,'records-in-table     %d\r\n',nt);
            for kt=1:nt
                fprintf(fid,'%0.7E \t%0.7E \r\n',tim(kt)*Tfact,eta(kt)); %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
            end                
        case 7
            fprintf(fid,'parameter           ''bed level change'' unit ''[m/s]''\r\n');
            fprintf(fid,'records-in-table     %d\r\n',nt);
            for kt=1:nt
                fprintf(fid,'%0.7E \t%0.7E \r\n',tim(kt)*Tfact,deta_dt(kt)); %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
            end        
        case 5
            for kf=1:nf
                fprintf(fid,'parameter           ''transport excl pores Sediment%d'' unit ''[m³/s/m]''\r\n',kf);
            end
            fprintf(fid,'records-in-table     %d\r\n',nt);
            for kt=1:nt
                fprintf(fid,'%0.7E \t',tim(kt)*Tfact);
                for kf=1:nf
                    fprintf(fid,'%0.7E \t',transport(kt,kf));
                end
                fprintf(fid,'\r\n');
            end
        otherwise
            error('IBedCond not accepted')
    end
    fprintf(fid,'\r\n');
end %for 

%% CLOSE

write_local_and_copy('close',fid,fname_local,simdef.file.bcm)

end %function
