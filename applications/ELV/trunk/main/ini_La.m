%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 207 $
%$Date: 2018-05-25 15:01:41 +0200 (Fri, 25 May 2018) $
%$Author: v.chavarriasborras@tudelft.nl $
%$Id: ini_La.m 207 2018-05-25 13:01:41Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/ini_La.m $
%
%ini_La this function creates the initial active layer thickness vector
%
%La=ini_La(input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function La=ini_La(input,fid_log)
%comment out fot improved performance if the version is clear from github
% version='1';
% fprintf(fid_log,'ini_La version: %s\n',version);

switch input.mor.Latype
    case {1,4} %constant active layer thickness
        La=repmat(input.mor.La(1),1,input.mdv.nx);               
end
