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

function h_out=normal_flow_h(Q,B,cf,slope,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);
addOptional(parin,'h0',1);
addOptional(parin,'hydraulic_radius',1);

parse(parin,varargin{:});

g=parin.Results.g;
h0=parin.Results.h0;
hydraulic_radius=parin.Results.hydraulic_radius;

%%

C=sqrt(g/cf);
switch hydraulic_radius
    case 1
        F=@(h)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
    case 2
        F=@(h)Q/B/h-C*sqrt(h*slope);
    otherwise
        error('Implement.')
end
h_out=fzero(F,h0);

end %function


