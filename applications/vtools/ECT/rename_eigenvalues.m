%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17251 $
%$Date: 2021-05-03 16:39:50 +0200 (Mon, 03 May 2021) $
%$Author: chavarri $
%$Id: rename_matrices.m 17251 2021-05-03 14:39:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/rename_matrices.m $
%

function [eigen_x,eigen_y]=rename_eigenvalues(flg,eigen_all,eigen_all_qs,eigen_all_dLa,eigen_all_ad,eigen_all_2Dx,eigen_all_2Dy,eigen_all_2Dx_sf,eigen_all_2Dy_sf,eigen_all_SWx,eigen_all_SWy,eigen_all_SWx_sf,eigen_all_SWy_sf,eigen_all_SWEx,eigen_all_SWEy,eigen_all_SWEx_sf,eigen_all_SWEy_sf,eigen_all_Dm,eigen_all_2Dx_d,eigen_all_2Dy_d);

% function [Ax_1,Ay_1,Dx_1,Dy_1,B_1,C_1,M_pmm]=rename_matrices(flg,ECT_matrices,alpha_pmm)
% v2struct(ECT_matrices)

if numel(flg.anl)>1
    error('flg.anl~=1')
end

eigen_x=NaN;
eigen_y=NaN;

%% rename matrix
switch flg.anl
    case 1 
        eigen_x=eigen_all;
    case 2
        eigen_x=eigen_all_qs;
    case 6
        eigen_x=eigen_all_2Dx;
        eigen_y=eigen_all_2Dy;
    case 7
        eigen_x=eigen_all_2Dx_sf;
        eigen_y=eigen_all_2Dy_sf;
    case 8
        eigen_x=eigen_all_SWx;
        eigen_y=eigen_all_SWy;
    case 9
        eigen_x=eigen_all_SWx_sf;
        eigen_y=eigen_all_SWy_sf;
    case 10
        eigen_x=eigen_all_SWEx;
        eigen_y=eigen_all_SWEy;
    case 11
        eigen_x=eigen_all_SWEx_sf;
        eigen_y=eigen_all_SWEx_sf;
    otherwise
        error('do')
%     case 12
%         eigen_x=eigen_all_SWx;
%         eigen_y=eigen_all_SWy;
%     case 14
%         eigen_x=eigen_all_SWx;
%         eigen_y=eigen_all_SWy;
end

