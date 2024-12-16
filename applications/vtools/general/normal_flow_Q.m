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
%compute normal flow

function q_out=normal_flow_Q(h,cf,slope,B,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);
addOptional(parin,'Q0',100);
addOptional(parin,'hydraulic_radius',1);

parse(parin,varargin{:});

g=parin.Results.g;
Q0=parin.Results.Q0;
hydraulic_radius=parin.Results.hydraulic_radius;

%%

C=sqrt(g/cf);
switch hydraulic_radius
    case 1
        F=@(Q)Q-C*sqrt(B*h/(B+2*h)*slope)*h*B;
    case 2
        F=@(Q)Q-C*sqrt(h*slope)*h*B;
    otherwise
        error('Implement.')
end
q_out=fzero(F,Q0);

end %function