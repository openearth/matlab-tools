% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17637 $
%$Date: 2021-12-08 22:21:26 +0100 (Wed, 08 Dec 2021) $
%$Author: chavarri $
%$Id: mkdir_check.m 17637 2021-12-08 21:21:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/mkdir_check.m $
%

function [c_anl,eig_i_morpho]=ECT_celerity_growth(ECT_matrices,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'kwx',2*pi/0.01);
addOptional(parin,'kwy',2*pi/0.01);

parse(parin,varargin{:});

kwx=parin.Results.kwx;
kwy=parin.Results.kwy;

%% CALC

in_2D.kwx_v=kwx;
in_2D.kwy_v=kwy;
in_2D.flg_disp=0;
[eig_r,eig_i,kwx_v,kwy_v]=twoD_study(ECT_matrices,in_2D);

%growth rate
eig_i_morpho=max(eig_i); %!!! ATT I think it is always max, but I should double check
% max_gr_m_w=simdef.ini.noise_amp.*exp(eig_i_morpho.*tim_v);
% gr_anl=diff(max_gr_m_w)./diff(tim_v); 

%celerity
eig_r(abs(eig_r)<1e-16)=NaN;
[m_s,p_s]=sort(abs(eig_r),2);
[nc,ne]=size(eig_r);
eig_r_morph=NaN(size(eig_r,1),ne-3);
for kc=1:nc
    eig_r_morph(kc,:)=eig_r(kc,p_s(kc,1:ne-3));
end

c_anl=max(eig_r_morph)./in_2D.kwx_v;

end %function