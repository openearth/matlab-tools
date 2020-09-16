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
%$Id: solve_nfbc2_pdf.m 203 2018-05-16 06:20:37Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/solve_nfbc2_pdf.m $
%
function obj = solve_nfbc2_pdf(X,input,dq,pq,AL,ib)
%solve_sedigraph computes the slope and surface fraction 
% VERSION 1

%INPUT:
%   -X(1) for slope, remainder for fractions
%   -input for parmaters
%   -Qw: equidistant spaced hydrograph
%   -AL: mean annual load per fraction
%
%OUTPUT:
%   -

%HISTORY:
%
%1600901
%   L-First creation

% Compute normal flow depth
input.grd.B = X(1);
dq = (dq'/input.grd.B(1,1));
%ib = X(1);
h = (input.frc.Cf(1).*dq.^2/(9.81*ib)).^(1/3);

% Get lengths
nm = length(h);
nf = length(X);

% Initialize fractions
if nf>1
	%F1 = 1-sum(X(2:end));
	%Mak = repmat([F1;X(2:end-1)'],1,nm);
	Mak = repmat(X(2:end)',1,nm);
	La = ones(1,nm);
	if min(Mak)<0
    		warning('Negative fractions are not allowed. Revisit solver');
	end

else
	Mak = NaN*ones(size(h));
	La = NaN*ones(size(h));
end

Cf=input.frc.Cf(1).*ones(size(h));

if isfield(input,'tra.calib')==1
    [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dq,Cf,La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,input.tra.calib,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
else
    [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dq,Cf,La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1              ,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
end


% Objectives:
Computed_load = sum(qbk.*repmat(pq',1,nf));
Annual_load = AL'/input.grd.B(1,1);
obj = Computed_load-Annual_load;
end

