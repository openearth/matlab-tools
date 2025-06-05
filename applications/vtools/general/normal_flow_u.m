%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19050 $
%$Date: 2023-07-14 09:55:51 +0200 (Fri, 14 Jul 2023) $
%$Author: chavarri $
%$Id: normal_flow_h.m 19050 2023-07-14 07:55:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/normal_flow_h.m $
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


