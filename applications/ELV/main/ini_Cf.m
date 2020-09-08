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
%ini_Cf is a function that creates the initial friction coefficient vector
%
%Cf=ini_Cf(input,fid_log)
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

function Cf=ini_Cf(input,La,fid_log)
%comment out fot improved performance if the version is clear from github
% version='1';
% fprintf(fid_log,'ini_Cf version: %s\n',version);

switch input.frc.Cf_type
    case 1 %constant friction
        Cf=input.frc.Cf(1).*ones(1,input.mdv.nx); 
    case 4 %depending on active layer
        Cf=input.frc.Cf_param(1).*La+input.frc.Cf_param(2);
end
