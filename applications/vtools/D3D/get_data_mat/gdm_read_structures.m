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
%Wrap of `D3D_read_structures`

function all_struct=gdm_read_structures(simdef,flg_loc)

if flg_loc.do_plot_structures
    all_struct=D3D_read_structures(simdef(1),'fpath_rkm',flg_loc.fpath_rkm); %check that either it is fine if empty or check emptyness for filling <in_p>
else
    all_struct=struct('name',[],'xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

end %function