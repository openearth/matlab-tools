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
%Discharge in a General Structure (Section 12.3.5 D-Flow FM User Manual,
%79968)

function [Q,is_free]=Q_general_structure(c_wd,c_wf,w_s,z_s,u,etaw_u,etaw_d,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81);

parse(parin,varargin{:});

g=parin.Results.g;

%% CALC

E1=etaw_u+u^2/(2*g);
h_c=2/3*(E1-z_s);
h_s=etaw_d-z_s;

is_free=h_s<h_c;
if is_free
    %free weir flow
    Q=c_wf*w_s*2/3*sqrt(2/3*g)*(E1-z_s)^(3/2);
else
    %submerged weir flow
    Q=c_wd*w_s*h_s*sqrt(2*g*(E1-(z_s+h_s)));
end