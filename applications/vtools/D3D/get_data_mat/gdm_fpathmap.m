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

fpath_map=simdef.file.map;
if simdef.D3D.structure==4
    %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
    fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx),filesep]); 
else
    fpath_map_loc=fpath_map;
end

end %function