%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 203 $
%$Date: 2018-05-16 08:20:37 +0200 (Wed, 16 May 2018) $
%$Author: v.chavarriasborras@tudelft.nl $
%$Id: get_sedigraph.m 203 2018-05-16 06:20:37Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/get_sedigraph.m $
%
%get_sedigraph does this and that
%
%Qb = get_sedigraph(Qw,input,S,Fk)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%161128
%   -L. Created for the first time

function Qb = get_sedigraph(Qw,input,S,Fk)
% S is equilibrium slope
% Fk is all the fractions; we select all but the coarsest which is
% 1-sum(others)
input = add_sedflags(input);
if numel(input.sed.dk)>1
    La = ones(1,numel(Qw));
    Mak = repmat(Fk(1:end-1)',1,numel(Qw));
else
    La = NaN*ones(1,numel(Qw));
    Mak = NaN*ones(1,numel(Qw));
end    
h = (input.frc.Cf(1).*(Qw/input.grd.B(1,1)).^2/(9.81*S)).^(1/3);
Cf = input.frc.Cf(1).*ones(1,numel(Qw)); 
if isfield(input,'tra.calib')==1
else 
    input.tra.calib =1;
end
[qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,Qw/input.grd.B(1,1),Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,input.tra.calib,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
Qb = qbk*input.grd.B(1,1);
end
