%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%
%Only loop of eigenvalues in 2D study.

function [eig_r,eig_i]=twoD_study_eigenvalues(pert_anl,kwx_vi,kwy_vi,Dx,Dy,C,Ax,Ay,B,M_pmm)

nc=numel(kwx_vi,1);
ne=size(Ax,1);

eig_r=NaN(nc,ne);
eig_i=NaN(nc,ne);

for kc=1:nc
    kwx=kwx_vi(kc);
    kwy=kwy_vi(kc);
 
    [~,~,~,~,eigen_R]=ECT_M(pert_anl,kwx,kwy,Dx,Dy,C,Ax,Ay,B,M_pmm);
    
    eig_r(kc,:)=real(eigen_R); 
    eig_i(kc,:)=imag(eigen_R);
end %kc

end %function