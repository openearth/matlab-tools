%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 07:25:35 +0200 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: normal_flow_h.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/normal_flow_h.m $
%
%compute normal flow

function var_out=normal_flow_s(Q,B,cf,h,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);

parse(parin,varargin{:});

g=parin.Results.g;

%%

C=sqrt(g/cf);
F=@(slope)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
var_out=fzero(F,1);

end %function


