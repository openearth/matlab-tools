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
%$Id: Mak2Fak.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/Mak2Fak.m $
%
%mean_grain_size computes the mean grain size
%
%Fak=Mak2Fak(Mak,La,input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%180605
%   -V. Created for the first time.
%


function Fak=Mak2Fak(Mak,La,input,fid_log)


%% 
%% RENAME
%% 

nx=input.mdv.nx;
nf=input.mdv.nf;

%%
%% CALC
%%

if nf==1 %unisize calculation (treated differently due to effective fractions)
    Fak=ones(1,nx);
else %multisize calculation
    Fak=NaN(nf,nx); %preallocate volume fractions
    Fak(1:nf-1,:)=Mak./repmat(La,nf-1,1); %effective fractions
    Fak(nf,:)=ones(1,nx)-sum(Fak(1:nf-1,:),1); %all fractions
end %isempty(Mak)

end %function


