%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17936 $
%$Date: 2022-04-05 13:43:17 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: twoD_study.m 17936 2022-04-05 11:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%

function [M,eigenvector,eigenvalue,eigenvectorL,eigenvalue_v]=ECT_M(pert_anl,kwx,kwy,Dx,Dy,C,Ax,Ay,B,M_pmm)

switch pert_anl
        case 1 %full
            M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy-B*1i; 
        case 2 %no friction
            M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy; 
        case 3 %no friction no diffusion
            M=Ax*kwx+Ay*kwy; 
        case 4 %full PMM
            M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy-inv(M_pmm)*B*1i; 
%             M=Dx_1*kwx^2*1i+Dy_1*kwy^2*1i+C_1*kwx*kwy*1i+inv(M_pmm)*Ax_1*kwx+inv(M_pmm)*Ay_1*kwy-inv(M_pmm)*B_1*1i; 
        case 5 %no friction PMM
            M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
        case 6 %no friction no diffusion PMM
            M=inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
        otherwise
            error('implement')
end
    
%eigen_R=eig(M);
[eigenvector,eigenvalue,eigenvectorL]=eig(M);
eigenvalue_v=diag(eigenvalue);

end %function