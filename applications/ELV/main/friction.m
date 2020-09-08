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
%$Id: friction.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/friction.m $
%
%friction is a function that computed the dimensionless friction coefficient
%
%Cf=friction(h,Mak,Cf_old,input,fid_log,kt)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function Cf=friction(h,Mak,Cf_old,La,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='1';
% if kt==1; fprintf(fid_log,'friction version: %s\n',version); end 


%%

switch input.frc.Cf_type
    case 1 %constant friction
        Cf=Cf_old;
    case 2 %friction related to grain size
        error('not yet implemented')
    case 3 %friction related to flow depth
        error('not yet implemented')    
    case 4
        Cf=input.frc.Cf_param(1).*La+input.frc.Cf_param(2);
end
