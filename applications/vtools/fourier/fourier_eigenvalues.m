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
