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
%$Id: check_sed.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/check_sed.m $
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