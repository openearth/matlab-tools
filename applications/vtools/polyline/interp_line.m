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

function y=interp_line(xv,yv,x)
y=(yv(2)-yv(1))/(xv(2)-xv(1)).*(x-xv(1))+yv(1);
end