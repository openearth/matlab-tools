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

function in_p=gdm_read_plot_along_rkm(in_p,flg_loc)

if flg_loc.do_rkm_disp
    rkm_file=gdm_read_rkm_file(flg_loc.fpath_rkm_disp);
    in_p.rkm=rkm_file;
end

end %function