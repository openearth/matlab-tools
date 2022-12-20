%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18607 $
%$Date: 2022-12-08 08:02:01 +0100 (Thu, 08 Dec 2022) $
%$Author: chavarri $
%$Id: normal_flow_s.m 18607 2022-12-08 07:02:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/normal_flow_s.m $
%
%compute normal flow

function var_out=normal_flow_Cf(Q,B,h,slope,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);

parse(parin,varargin{:});

g=parin.Results.g;

%%

F=@(C)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
var_out=fzero(F,0.1);
var_out=g/var_out^2;

end %function


