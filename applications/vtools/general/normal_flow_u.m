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

function u_out=normal_flow_u(Q,B,cf,slope,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);
addOptional(parin,'u0',1);
addOptional(parin,'hydraulic_radius',1);

parse(parin,varargin{:});

g=parin.Results.g;
u0=parin.Results.u0;
hydraulic_radius=parin.Results.hydraulic_radius;

%%

C=sqrt(g/cf);
switch hydraulic_radius
    case 1
        F=@(u)u-C*sqrt(B*(Q/B/u)/(B+2*(Q/B/u))*slope);
    case 2
        F=@(u)u-C*sqrt(Q/B/u*slope);
    otherwise
        error('Implement.')
end
u_out=fzero(F,u0);

end %function


