%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 27 $
%$Date: 2021-09-01 16:22:33 +0200 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: fig_his_xt.m 27 2021-09-01 14:22:33Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/fig_his_xt.m $
%

function y=interp_line_closest(xv_all,yv_all,x,x_thres)

idx_2=find(xv_all>x,1,'first');
if isempty(idx_2)
    idx_2=find(xv_all==x,1,'first');
    if isempty(idx_2)
        y=NaN;
    else
        y=yv_all(idx_2);
    end
else
%     idx_1=find(xv_all<x,1,'last'); 
    idx_1=idx_2-1;
    if idx_1==0
        y=NaN;
    else
        
        if x+x_thres>xv_all(idx_2) && x-x_thres<xv_all(idx_1) %good
    %     xv=xv_all([idx_1,idx_2]);
    %     yv=yv_all([idx_1,idx_2]);
            y=interp_line(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
        else
            y=NaN;
        end
    end
end

end