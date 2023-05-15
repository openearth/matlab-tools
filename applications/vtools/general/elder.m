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
%

function [nu,nu_s]=elder(h,u,ci,varargin)

parin=inputParser;

addOptional(parin,'friction_type',1);

parse(parin,varargin{:});

friction_type=parin.Results.friction_type;

g=9.81;
kappa=0.41;

switch friction_type
    case 1 %C_f (non-dimensional)
        cf=ci;
    case 2 %C (Chezy)
        cf=g/ci^2;
    case 3 %Manning
        C=h^(1/6)/ci;
        cf=g/C^2;
end

ust=sqrt(cf)*u;
nu=1/6*kappa*h*ust;
nu_s=5.93*h*ust;

end %function

