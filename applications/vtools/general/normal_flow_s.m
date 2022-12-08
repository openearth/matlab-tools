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

parse(parin,varargin{:});

g=parin.Results.g;

%%

C=sqrt(g/cf);
F=@(slope)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
var_out=fzero(F,1);

end %function


