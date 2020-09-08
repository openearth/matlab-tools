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
%$Id: Mak2Fak.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/Mak2Fak.m $
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


