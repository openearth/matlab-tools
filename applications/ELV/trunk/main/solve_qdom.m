%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: solve_qdom.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/solve_qdom.m $
%
function obj = solve_qdom(X,input,ib,F,AL,k)
%solve_sedigraph computes the slope and surface fraction 
% VERSION 1

%INPUT:
%   -X: dominant discharge
%   -input for parmaters
%   -ib: slope
%   -F: fraction of gravel 
%   -Qw: equidistant spaced hydrograph
%   -AL: mean annual load per fraction
%
%OUTPUT:
%   -

%HISTORY:
%
%1600901
%   L-First creation

Qw = X/input.grd.B(1);
h = (input.frc.Cf.*Qw.^2/(9.81*ib)).^(1/3);

% Get lengths
nm = length(h);
nf = length(AL);

% Initialize fractions
Mak = F;%1-F;
Cf=input.frc.Cf.*ones(size(h));  
La = ones(1,nm);
[qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h,Qw,Cf,La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
              
% Objectives:
% - Total mass per fraction is transported
Computed_load = sum(qbk(k));
Annual_load = sum(AL(k))/input.grd.B(1);
obj = Computed_load-Annual_load;
end

