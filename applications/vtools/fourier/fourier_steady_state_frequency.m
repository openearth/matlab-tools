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
%Compute the Fourier coefficients of a steady-state solution for `ne-1`
%eignevalues given the perturbation in one dimension. 

function [P2all]=fourier_steady_state_frequency(fx2,fy2,P2,dim_ini,M,R)

%% PARSE

%% CALC

%% dimensions

ne=size(R,1);
nmx=numel(fx2);
nmy=numel(fy2);

%preallocate
P2all=NaN(ne,nmy,nmx);

%indices of steady state variables
dim_steady=1:1:ne;
dim_steady(dim_ini)=[];

%% loop

for kmx=1:nmx
    for kmy=1:nmy
        cx_fou=P2(kmy,kmx);

        M_flow=M(dim_steady,dim_steady,kmx,kmy);
        M_force=M(dim_steady,dim_ini,kmx,kmy);
        b=-M_force.*cx_fou;
        c=M_flow\b;

        %save fourier coefficients
        P2all(dim_steady,kmy,kmx)=c;
        P2all(dim_ini,kmy,kmx)=cx_fou;
    end %kmy
end %kmx

end %function