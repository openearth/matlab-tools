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
%Compute evolution of fourier coefficients
%
%INPUT:
%	-x      = independent variable; double, [1,nx];
%   -y      = independent variable; double, [1,ny];
%   -t      = independent variable; double, [1,nt];
%   -P2     = double-sided Fourier coefficients weighted by number of modes. 
%             It can be for a single variable along dimension `dim_in`; double, [ny,nx];
%             It can be for all variables; double, [ne,ny,nx];
%	-R      = right eigenvectors matrix; double, [ne,ne,nx,ny]
%	-omega  = eigenvalues vector [ne,nx,ny]
%	-dim_in = dimension (i.e., equation number) in which the initial perturbation is applied; double, [1,1]
%
%OUTPUT:
%	-Q      = solution for all modes; double, [ne,nx,ny,nt,nx,ny];
%	-Q_rec  = solution adding modes; double, [ne,nx,ny,nt];

function [Q,Q_rec]=fourier_evolution(x,y,t,P2,R,omega,dim_ini,varargin)

%% domain

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);
[x_in,y_in]=meshgrid(x,y);

%% CALC

[Q,Q_rec]=fourier_evolution_frequency(fx2,fy2,x_in,y_in,t,P2,R,omega,dim_ini,varargin{:});

end %function