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
%

function fpath_map_loc=gdm_fpathmap(simdef,sim_idx)

if isfield(simdef.file,'map')==0
    messageOut(NaN,'No map file available.')
    fpath_map='';
else
    fpath_map=simdef.file.map;
end
if simdef.D3D.structure==4
    %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
    fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx),filesep]); 
elseif simdef.D3D.structure==5
    %it relies on the path in <simdef> to be the one to the first output
    fpath_map_loc=strrep(fpath_map,sprintf('%d.min',simdef.file.output_time(1)),sprintf('%d.min',simdef.file.output_time(sim_idx+1))); %in <sim_idx> we have kf-1
else
    fpath_map_loc=fpath_map;
end

end %function