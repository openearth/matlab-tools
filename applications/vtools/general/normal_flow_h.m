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

parse(parin,varargin{:});

g=parin.Results.g;
h0=parin.Results.h0;

%%

C=sqrt(g/cf);
F=@(h)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
h_out=fzero(F,h0);

end %function


