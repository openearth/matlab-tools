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
%$Id: mean_grain_size.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/mean_grain_size.m $
%
%mean_grain_size computes the mean grain size
%
%Dm=mean_grain_size(Mak,La,input,fid_log)
%
%INPUT:
%   -Fak [nf,nx]
%
%OUTPUT:
%   -
%
%HISTORY:
%180605
%   -V. Created for the first time.
%


function Dm=mean_grain_size(Fak,input,fid_log)


%% 
%% RENAME
%% 

nx=input.mdv.nx;
dk=input.sed.dk; %[nf,1]

dk=reshape(dk,numel(dk),1);
%%
%% CALC
%%

switch input.tra.Dm
    case 1 %geometric
        Dm=2.^sum(Fak.*repmat(log2(dk),1,nx),1); %[nf,nx]
    case 2 %arithmetic
        Dm=sum(Fak.*repmat(dk,1,nx),1); %[nf,nx]
end
end %function


