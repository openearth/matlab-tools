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

function simdef=D3D_rework_nodes(simdef)

if isfield(simdef.D3D,'cluster')==0
    simdef.D3D.cluster='h7';
end
if isfield(simdef.D3D,'nodes')==0
    simdef.D3D.nodes=1;
end
if isfield(simdef.D3D,'tasks_per_node')==0
    simdef.D3D.tasks_per_node=1;
end
if isfield(simdef.D3D,'partition')==0
    simdef.D3D.partition='1vcpu';
end
if isfield(simdef.D3D,'time_duration')==0
%     simdef.D3D.time_duration=days(32);
%     simdef.D3D.time_duration=hours(5);
    simdef.D3D.time_duration=days(10);
end

if simdef.D3D.tasks_per_node*simdef.D3D.nodes>1 && strcmp(simdef.D3D.partition,'1vcpu')
    error('You cannot compute parallel in 1vcpu partition');
end
switch simdef.D3D.partition
    case {'1vcpu','4vcpu'}
        tim_lim=days(32);
    case {'16vcpu','24vcpu','48vcpu'}
        tim_lim=days(24);
    otherwise
        error('Partition %s does not exist in h7',simdef.D3D.partition);
end
if simdef.D3D.time_duration>tim_lim
    error('The time limit exceeds the cluster configuration.')
end

end %function