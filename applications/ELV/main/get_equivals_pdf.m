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
%$Id: get_equivals_pdf.m 168 2017-08-02 10:08:36Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/get_equivals_pdf.m $
%
%get_equivals_pdf does this and that
%
%[S,Fk] = get_equivals_pdf(pq,dq,input,AL,sedp,X0)
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

function [S,Fk] = get_equivals_pdf(pq,dq,input,AL,sedp,X0)
ALp = AL * sedp;
input = add_sedflags(input);
F = @(X)solve_nfbc_pdf(X,input,dq,pq,ALp);
options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
[X_s,~,~,~]=fsolve(F,X0,options);

rel_error = solve_nfbc_pdf(X_s,input,dq,pq,ALp)./ALp';
if max(abs(rel_error))>0.001
    disp('Sum of objective function of different transport fractions: (should be zero)')
    rel_error
    warning('Not sure if answer is trustworthy');
end

S = X_s(1);
Fk = X_s(2:end);
Fk = [Fk 1-sum(Fk)];

if Fk < 0
    error('Fk<0')
elseif Fk >1
    error('Fk>1')
end

end
