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
%$Id: mean_grain_size.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/mean_grain_size.m $
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


