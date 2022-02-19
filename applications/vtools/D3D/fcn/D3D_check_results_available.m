%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17759 $
%$Date: 2022-02-14 10:50:54 +0100 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_results_time.m 17759 2022-02-14 09:50:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_results_time.m $
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
