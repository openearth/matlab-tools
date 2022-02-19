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
%Check if all results files are available

function [fpath_missing,kpart_missing]=D3D_check_results_available(fdir_sim,npart)

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);

%map
kmiss=0;
fpath_missing={};
kpart_missing=[];
for kpart=1:npart
    fpath_map=fullfile(simdef.file.output,sprintf('%s_%04d_map.nc',simdef.file.runid,kpart-1));
    if exist(fpath_map,'file')~=2
        kmiss=kmiss+1;
        fpath_missing{kmiss}=fpath_map;
        kpart_missing=cat(1,kpart_missing,kpart-1);
    end
end %kpart

end %function
