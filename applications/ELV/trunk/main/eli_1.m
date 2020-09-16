%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: eli_1.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/eli_1.m $
%
%eli_1 does this and that
%
%La_new=eli_1(La,ell_idx,in_f,input,fid_log,kt)
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

function La_new=eli_1(La,ell_idx,in_f,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='1';
% if kt==1; fprintf(fid_log,'eli_1 version: %s\n',version); end 

%%
%% RENAME
%%

nf=input.mdv.nf;

lb=in_f.lb;
ls=in_f.ls;
gamma=in_f.gamma;
mu=in_f.mu;
safetyfact=0.1;

%%
%% NEW La
%%

if nf==2
    La_new=La; %non-elliptic nodes with the same La
    switch input.mor.gsdupdate
        case 2
            La_new(ell_idx)=(1+safetyfact)./(lb(ell_idx)./(ls(ell_idx).*La(ell_idx)).*(1-2*gamma(ell_idx)./mu(ell_idx)-sqrt((2*gamma(ell_idx)./mu(ell_idx)-1).^2-1))); %dimensional maximum limit of the active layer domain 
        case 3
            La_new(ell_idx)=(1-safetyfact)./(lb(ell_idx)./(ls(ell_idx).*La(ell_idx)).*(1-2*gamma(ell_idx)./mu(ell_idx)+sqrt((2*gamma(ell_idx)./mu(ell_idx)-1).^2-1))); %dimensional lower limit of the active layer domain 
    end
else
    error('This needs to be implemented... and check the definitions of c, gamma,....')
end

end %function
















