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

[ECT_matrices,~]=call_ECT(ECT_input);
v2struct(ECT_matrices);

%% eigenvalues

[R,omega,M]=fourier_eigenvalues_frequency_matrices(Dx,Dy,Ax,Ay,B,C,M_pmm,fx2,fy2,pert_anl);

end %function