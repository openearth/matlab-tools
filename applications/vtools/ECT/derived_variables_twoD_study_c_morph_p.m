%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19858 $
%$Date: 2024-10-27 16:30:11 +0100 (Sun, 27 Oct 2024) $
%$Author: chavarri $
%$Id: derived_variables_twoD_study.m 19858 2024-10-27 15:30:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/derived_variables_twoD_study.m $
%
%Compute morphodynamic celerity based on eigenvalues.
%

function [c_morph_p,eig_r_morph_p,gr_morph_p]=derived_variables_twoD_study_c_morph_p(eig_r_p,eig_i_p,kwx_p)

[nc,ne]=size(eig_r_p);

% eig_r_p(abs(eig_r_p)<1e-16)=NaN; %why?
[~,p_s]=sort(abs(eig_r_p),2);
eig_r_morph_p=NaN(size(eig_r_p,1),ne-3);
gr_morph_p=NaN(size(eig_r_p,1),ne-3);
for kc=1:nc
    eig_r_morph_p(kc,:)=eig_r_p(kc,p_s(kc,1:ne-3));
    gr_morph_p(kc,:)=eig_i_p(kc,p_s(kc,1:ne-3));
end
c_morph_p=eig_r_morph_p./kwx_p;

end %function