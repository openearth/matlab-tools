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
%$Id: get_equivals2_pdf.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/get_equivals2_pdf.m $
%
%get_equivals2_pdf does this and that
%
%[B,Fk] = get_equivals2_pdf(pq,dq,input,AL,sedp,S,X0)
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

function [B,Fk] = get_equivals2_pdf(pq,dq,input,AL,sedp,S,X0)
ALp = AL * sedp;
input = add_sedflags(input);
F = @(X)solve_nfbc2_pdf(X,input,dq,pq,ALp,S);
options=optimoptions('fsolve','TolFun',1e-20,'TolX',1e-20,'display','none','MaxFunEvals',1000);
[X_s,~,~,~]=fsolve(F,X0,options);

disp('Sum of objective function of different transport fractions (width): (should be zero)')
sum(abs(solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)))
solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)
rel_error = solve_nfbc2_pdf(X_s,input,dq,pq,ALp,S)./ALp';

if max(abs(rel_error))>0.001;
    warning('Not sure if answer is trustworthy');
end

B = X_s(1);
Fk = X_s(2:end);
Fk = [Fk 1-sum(Fk)];

if Fk < 0
    error('Fk<0')
elseif Fk >1
    error('Fk>1')
end

end
