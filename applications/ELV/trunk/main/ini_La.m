%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: ini_La.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/ini_La.m $
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
