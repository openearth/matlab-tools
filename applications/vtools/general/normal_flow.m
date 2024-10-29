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
%INPUT:
% hydraulic_radius: 1=considering `B*h/(B+2h)`; 2=considering `h`

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
addOptional(parin,'hydraulic_radius',1);
addOptional(parin,'h0',1);

parse(parin,varargin{:});

Q=parin.Results.Q;
h=parin.Results.h;
B=parin.Results.B;
s=parin.Results.s;
Cf=parin.Results.Cf;
C=parin.Results.C;
g=parin.Results.g;
hydraulic_radius=parin.Results.hydraulic_radius;
h0=parin.Results.h0;

%% SELECT

out_C=false;
if isnan(C)
    out_C=true;
    C=sqrt(g/Cf); %if `Cf=NaN` it will be NaN and hence the unknown
end

which_v=[Q,h,B,s,C];
idx_do=find(isnan(which_v));
if numel(idx_do)>1
    error('Only one unknown allowed.')
end

%% CALC

switch idx_do
    case 1
        val_out=normal_flow_Q(h,g/C^2,s,B,'g',g,'hydraulic_radius',hydraulic_radius);
    case 2
        val_out=normal_flow_h(Q,B,g/C^2,s,'g',g,'hydraulic_radius',hydraulic_radius,'h0',h0);
    case 4
        val_out=normal_flow_s(Q,B,g/C^2,h,'g',g,'hydraulic_radius',hydraulic_radius);
    case 5
        val_out=normal_flow_Cf(Q,B,h,s,'g',g,'hydraulic_radius',hydraulic_radius);
        if out_C
            val_out=sqrt(g/val_out);
        end
    otherwise
      
end


end %function


