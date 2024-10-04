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

function [s,xlab_str,xlab_un]=gdm_s_rkm_cen(flg_loc,data)

%better to have default in figure, to be able to overwrite
    xlab_str='';
    xlab_un=[];
if flg_loc.do_rkm
    xlab_str='rkm';
    xlab_un=1/1000;
end

if flg_loc.do_staircase
    if flg_loc.do_rkm
        error('do')
    else
        s=data.Scor_staircase;
    end
else
    if flg_loc.do_rkm
        s=data.rkm_cen;
    else
        s=data.Scen;
%         in_p.s_staircase=data.Scor_staircase;
    end
end

end %function