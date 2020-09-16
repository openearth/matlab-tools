%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 168 $
%$Date: 2017-08-02 12:08:36 +0200 (Wed, 02 Aug 2017) $
%$Author: V $
%$Id: get_equivals.m 168 2017-08-02 10:08:36Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/get_equivals.m $
%
%get_equivals computes the normal load distribution given a hydrograph and the annual load
%
%[S,Fk] = get_equivals(Qw,input,AL,sedp,X0)
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
%

function [S,Fk] = get_equivals(Qw,input,AL,sedp,X0)
ALp = AL * sedp;
input = add_sedflags(input);
F = @(X)solve_nfbc(X,input,Qw,ALp);
options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
[X_s,~,~,~]=fsolve(F,X0,options);

rel_error = solve_nfbc(X_s,input,Qw,ALp)./ALp;
if max(abs(rel_error))>0.001
    warning('Not sure if answer is trustworthy');
    rel_error
end

S = X_s(1);
Fk = X_s(2:end);
Fk = [Fk 1-sum(Fk)];
end
