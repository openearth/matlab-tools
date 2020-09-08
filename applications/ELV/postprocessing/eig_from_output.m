%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 231 $
%$Date: 2020-04-06 16:00:58 +0200 (Mon, 06 Apr 2020) $
%$Author: chavarri $
%$Id: eig_from_output.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/postprocessing/eig_from_output.m $
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

