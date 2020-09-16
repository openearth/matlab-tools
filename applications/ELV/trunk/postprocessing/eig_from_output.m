%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 246 $
%$Date: 2020-07-08 10:57:48 +0200 (Wed, 08 Jul 2020) $
%$Author: chavarri $
%$Id: eig_from_output.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/postprocessing/eig_from_output.m $
%
%function_name does this and that
%
%
%INPUT:
%
%OUTPUT:
%   -
%
%HISTORY:
%180320
%   -V. Created for the first time.
%

function lambdas=eig_from_output(output_m)

%% 
%% RENAME
%%


%%
%% CALC 
%%

%% find fIk

%% compute lambda

[ell_idx,out]=elliptic_nodes(u,h,Cf,La,qbk,Mak,fIk,input,fid_log,kt);

end %function

