%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 217 $
%$Date: 2018-11-23 15:24:08 +0100 (Fri, 23 Nov 2018) $
%$Author: v.chavarriasborras@tudelft.nl $
%$Id: check_mor.m 217 2018-11-23 14:24:08Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/check_mor.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%192202
%   -V. Created for the first time.

function input_out=check_sed(input,fid_log)

%order of size fractions
input.sed.dk=reshape(input.sed.dk,input.mdv.nf,1);

%% OUTPUT 

input_out=input;