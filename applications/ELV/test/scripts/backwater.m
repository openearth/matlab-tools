%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 157 $
%$Date: 2017-07-27 17:53:42 +0200 (Thu, 27 Jul 2017) $
%$Author: V $
%$Id: backwater.m 157 2017-07-27 15:53:42Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/test/scripts/backwater.m $
%
%backwater does this and that
%
%\texttt{[U,H]=backwater(ib,Cf,Hdown,Q,input)}
%
%INPUT:
%   -\texttt{ib} = slope vector
%   -\texttt{Cf} = dimensionless representative friction
%   -\texttt{Q} = upstream discharge (constant), or a discharge vector;
%
%OUTPUT:
%   -\texttt{U} = 
%   -\texttt{H} = 
%
%HISTORY:

function [U,H] = backwater(ib,Cf,Hdown,Q,input)

K=input.mdv.nx;
if numel(Q)==1
    Q = Q*ones(K,1);
end
if numel(ib)==1
    ib = ib*ones(K,1);
end

% Computes the entire profile
U = NaN*zeros(K,3);
H = NaN*zeros(K,1);
H(end) = Hdown;
U(end,:) = get_flow_velocities(input,K,Q(end),Hdown,ib(end));

for j=K-1:-1:1    
    [U(j,:), H(j)] = backwater_step(j,H(j+1),ib(j+1),Cf(j+1),Q(j+1),input);
end
end