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

function in_p=gdm_s_rkm_cen(in_p,flg_loc,data)

if flg_loc.do_rkm
    in_p.xlab_str='rkm';
    in_p.xlab_un=1/1000;
end

if flg_loc.do_staircase
    if flg_loc.do_rkm
        error('do')
    else
        in_p.s=data.Scor_staircase;
    end
else
    if flg_loc.do_rkm
        in_p.s=data.rkm_cen;
    else
        in_p.s=data.Scen;
        in_p.s_staircase=data.Scor_staircase;
    end
end

end %function