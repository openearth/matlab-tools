%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Discharge in a General Structure (Section 12.3.5 D-Flow FM User Manual,
%79968)

function [Q,is_free]=Q_weir_SRE(c_wf,w_s,z_s,u_u,u_d,etaw_u,etaw_d,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);

parse(parin,varargin{:});

g=parin.Results.g;

Sf_lim=0.82;

%% CALC

E1=etaw_u+u_u^2/(2*g);
E2=etaw_d+u_d^2/(2*g);
Sf=(E2-z_s)/(E1-z_s);

is_free=Sf<Sf_lim;
if is_free
    %free weir flow
    f=1;
else
    %submerged weir flow
    tab=[0.00,1.00;...
       0.20,0.99;...
       0.40,0.97;...
       0.60,0.96;...
       0.80,0.95;...
       0.90,0.90;...
       0.95,0.85;...
       1.00,0.82];
    tab=flipud(tab);
    F=griddedInterpolant(tab(:,2),tab(:,1));
    f=F(Sf);
end

Q=c_wf*w_s*f*2/3*sqrt(2/3*g)*(E1-z_s)^(3/2);

end %function