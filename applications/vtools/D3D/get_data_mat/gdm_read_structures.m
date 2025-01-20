%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19327 $
%$Date: 2023-12-21 14:04:16 +0100 (Thu, 21 Dec 2023) $
%$Author: chavarri $
%$Id: gdm_parse_summerbed.m 19327 2023-12-21 13:04:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_summerbed.m $
%
%Wrap of `D3D_read_structures`

function all_struct=gdm_read_structures(simdef,flg_loc)

if flg_loc.do_plot_structures
    all_struct=D3D_read_structures(simdef(1),'fpath_rkm',flg_loc.fpath_rkm); %check that either it is fine if empty or check emptyness for filling <in_p>
else
    all_struct=struct('name',[],'xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

end %function