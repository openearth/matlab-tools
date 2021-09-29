%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17273 $
%$Date: 2021-05-07 21:37:43 +0200 (Fri, 07 May 2021) $
%$Author: chavarri $
%$Id: absolute_limits.m 17273 2021-05-07 19:37:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
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
    case 1
        cf=ci;
    case 2
        cf=g/ci^2;
end

ust=sqrt(cf)*u;
nu=1/6*kappa*h*ust;
nu_s=5.93*h*ust;

end %function

