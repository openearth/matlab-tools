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

function var_out=normal_flow_s(Q,B,cf,h,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);
addOptional(parin,'hydraulic_radius',1);

parse(parin,varargin{:});

g=parin.Results.g;
hydraulic_radius=parin.Results.hydraulic_radius;

%%

C=sqrt(g/cf);
switch hydraulic_radius
    case 1
        F=@(slope)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
    case 2
        F=@(slope)Q/B/h-C*sqrt(h*slope);
    otherwise
        error('Implement.')
end
var_out=fzero(F,1);

end %function


