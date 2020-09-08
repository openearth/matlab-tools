%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
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

