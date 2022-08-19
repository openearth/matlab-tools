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

function [R,omega]=fourier_eigenvalues(x,y,ECT_input,pert_anl)

%%

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);

%% matrices

[ECT_matrices,sed_trans]=call_ECT(ECT_input);
v2struct(ECT_matrices);

%% eigenvalues

ne=numel(diag(ECT_matrices.Ax));
nmx=numel(fx2);
nmy=numel(fy2);

omega=NaN(ne,nmx,nmy);
R=NaN(ne,ne,nmx,nmy);
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        [~,R(:,:,kmx,kmy),~,~,omega(:,kmx,kmy)]=ECT_M(pert_anl,kx_fou,ky_fou,Dx,Dy,C,Ax,Ay,B,M_pmm);
    end
    fprintf('computing eigenvalues %4.2f %% \n',kmx/nmx*100);   
end
