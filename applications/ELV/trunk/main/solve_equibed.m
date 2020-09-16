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
%$Id: solve_equibed.m 203 2018-05-16 06:20:37Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/solve_equibed.m $
%
function obj = solve_equibed(X,H,input,dQ,pQ,AL)
%solve_Hdown computes H_down
% VERSION 3

%INPUT:
%   -input (ELV)
%   -X: mean bed elevation
%   -H: water surface elevation (element or vector)
%   -dQ: vector with discharge values
%   -pQ: vector with probability of occurence of discharge values
%   -AL: average load per fraction
%OUTPUT:
%   -

%HISTORY:
%
%1600825
%   -L. Updated to use only 100 modes
%       Made header
%160829
%   -L. Updated for mixed sediments

%% Initialization
% Water surface elevations.
if numel(H)==1 %if only one value is given, make a vector out of it.
    H = H*ones(size(dQ)); 
end

if numel(H)~=numel(dQ) %check that we have the same number of water depths then as discharges.
    error('check input');
end

% Probability of discharges
if isnan(pQ)==1
    pQ = ones(size(dQ))/numel(dQ);
end

% Make a vector out of the bed levels.
eta = X(1)*ones(size(dQ));
h = H - eta;

%% Compute the new mean bed elevation
switch input.mdv.nf
    case 1
        Cf=input.frc.Cf(1,1).*ones(size(h));
        La=NaN * ones(size(h));
        Mak=NaN * ones(size(h));
        [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dQ,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
        try
            obj = sum(qbk.*pQ)-AL;
        catch
            obj = sum(qbk.*pQ')-AL;
        end
    otherwise
        K = numel(dQ);
        Mak = repmat(X(:,2:end)',1,K)';
        Cf=input.frc.Cf(1,1).*ones(1,K);              
        La=input.mor.La.*ones(1,K);   
        if min(Mak)<0
            warning('Negative fractions are not allowed. Revisit solver');
        end
        [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,dQ,Cf,La,Mak,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);

        % Objectives per fraction
        CL = sum(qbk.*repmat(pQ,1,input.mdv.nf),1);
        obj = CL-AL;  
end
end

