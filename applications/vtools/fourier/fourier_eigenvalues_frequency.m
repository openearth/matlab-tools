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
%Compute eigenvalues and eigenvector for given frequencies.

function [R,omega,M]=fourier_eigenvalues_frequency(fx2,fy2,ECT_input,pert_anl)

[ECT_matrices,sed_trans]=call_ECT(ECT_input);
v2struct(ECT_matrices);

%% eigenvalues

ne=numel(diag(ECT_matrices.Ax));
nmx=numel(fx2);
nmy=numel(fy2);

omega=NaN(ne,nmx,nmy);
R=NaN(ne,ne,nmx,nmy);
M=R;
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        [M(:,:,kmx,kmy),R(:,:,kmx,kmy),~,~,omega(:,kmx,kmy)]=ECT_M(pert_anl,kx_fou,ky_fou,Dx,Dy,C,Ax,Ay,B,M_pmm);
    end %kmy
    fprintf('computing eigenvalues %4.2f %% \n',kmx/nmx*100);   
end %kmx

end %function