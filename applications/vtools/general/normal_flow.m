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

function val_out=normal_flow(varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'Q',NaN);
addOptional(parin,'h',NaN);
addOptional(parin,'B',NaN);
addOptional(parin,'s',NaN);
addOptional(parin,'Cf',NaN);
addOptional(parin,'C',NaN);
addOptional(parin,'g',9.81);

parse(parin,varargin{:});

Q=parin.Results.Q;
h=parin.Results.h;
B=parin.Results.B;
s=parin.Results.s;
Cf=parin.Results.Cf;
C=parin.Results.C;
g=parin.Results.g;

%% SELECT

if isnan(C)
    C=sqrt(g/Cf); %if `Cf=NaN` it will be NaN and hence the unknown
end

which_v=[Q,h,B,s,C];
idx_do=find(isnan(which_v));
if numel(idx_do)>1
    error('Only one unknown allowed.')
end

%% CALC

switch idx_do
%     case 1
%         normal_flow_Q
    case 2
        val_out=normal_flow_h(Q,B,g/C^2,s,'g',g);
    case 4
        val_out=normal_flow_s(Q,B,g/C^2,h,'g',g);
    otherwise
      
end


end %function


