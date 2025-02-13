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