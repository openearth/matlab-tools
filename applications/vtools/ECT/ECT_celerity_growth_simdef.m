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
%

function [c_morph_p,max_gr_p]=ECT_celerity_growth_simdef(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'kwx',2*pi/100);
addOptional(parin,'kwy',2*pi/100);

parse(parin,varargin{:});

kwx=parin.Results.kwx;
kwy=parin.Results.kwy;

%% CALC

ECT_input=D3D_input_2_ECT_input(simdef);
in_2D.flg=ECT_input.flg;

[ECT_matrices,sed_trans]=call_ECT(ECT_input);

%this
in_2D.kwy_v=kwx;
in_2D.kwx_v=kwy;

[eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
[kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);

end %function