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
%Compute eigenvalues and eigenvector for given frequencies and matrix.

function [R,omega,M]=fourier_eigenvalues_frequency_matrices(Dx,Dy,Ax,Ay,B,C,M_pmm,fx2,fy2,pert_anl,varargin)

%% PARSE

%simple input to speed up. This function may be called a lot.
do_disp=1;
if numel(varargin)>0
    do_disp=varargin{1,1};
end

%%

ne=numel(diag(Ax));
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
    if do_disp
        fprintf('computing eigenvalues %4.2f %% \n',kmx/nmx*100);   
    end
end %kmx

end %function