function [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%function [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%Computes volume exchange from beach to the dune
% 
%                               -(B-Bthr)/Bhalf
%    Vdunegrowth = Cmax * (1 - e               )
%
% INPUT:
%    B              Actual beach width [m] (Y-Ydune)
%    Bthr           Equilibrium beach width [m]
%    Cmax           Maximum volume exchange towards the dunes [m3/yr]
%    Bhalf          Half of maximum volume exchange [m]
%    
% OUTPUT:
%    Vdunegrowth    Actual volume that is transported from the beach to the dunes [m3/m/yr]
%
% EXAMPLE:
%   B     = 80;
%   Bthr  = 80;
%   Cmax  = 35;
%   Bhalf = 50;
%   [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%
% Copyright: Deltares, 2011
% Created by B.J.A. Huisman

Vdunegrowth = Cmax*(1-exp(-(B-Bthr)./Bhalf));
Vdunegrowth(Vdunegrowth<0)=0;