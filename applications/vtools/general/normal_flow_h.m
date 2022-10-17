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

function h_out=normal_flow_h(Q,B,cf,slope)

g=9.81;

C=sqrt(g/cf);
F=@(h)Q/B/h-C*sqrt(B*h/(B+2*h)*slope);
h_out=fzero(F,1);

end %function


