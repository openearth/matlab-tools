%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 157 $
%$Date: 2017-07-27 17:53:42 +0200 (Thu, 27 Jul 2017) $
%$Author: V $
%$Id: check_nour.m 157 2017-07-27 15:53:42Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/check_nour.m $
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
%170720
%   -V & Pepijn. Created for the first time.

function input_out=check_nour(input,fid_log)

if isfield(input.nour,'t')==0
    input.nour.t=NaN;
else
    if input.mdv.nf==1
        input.nour.dk_opt=NaN;
    end
end

%% OUTPUT 

input_out=input;