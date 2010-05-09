function varargout = delft3d_kelvin_wave_calculation(G, F, C,varargin)
%DELFT3D_KELVIN_WAVE_CALCULATION   analytical solution (iterative friction) of Kelvin wave
%
%  [ETA,<VEL>] = delft3d_kelvin_wave_calculation(G, F, C,<ifreq>)
%
%See also: delft3d_kelvin_wave

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Walter Jacobs and Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   if nargin==4
      ifreq  = varargin{1};
      F.eta0 = F.eta0(ifreq);
      C.Tt   = C.Tt  (ifreq);
      C.w    = C.w   (ifreq);
      C.L0   = C.L0  (ifreq);
      C.k0   = C.k0  (ifreq);
   end


   T.t0 = 0;% time sampling points

   OPT.plot_iteration = 0;

%% Iteration parameters

   OPT.v_residue_min = 0.001;
   OPT.n_iterations  = 0;
   OPT.relaxation    = 0.5;
   OPT.v_residue     = Inf;

%% Initialize

   VEL.abs0         = repmat((1+0i),size(G.coast.x));
   VEL.complex      = repmat((1+0i),size(G.coast.x));
   VEL.abs          = repmat((1+0i),size(G.coast.x));
   VEL.arg          = repmat((1+0i),size(G.coast.x));

   while max(OPT.v_residue(:)) > OPT.v_residue_min; 
       
      OPT.n_iterations = OPT.n_iterations +1;
      
   %% Friction
   
      VEL.abs0         = VEL.abs0 + OPT.relaxation.*(VEL.abs - VEL.abs0);
      VEL.abs          = nan;
   
      kappa            = (8/(3*pi))*C.Cf*(VEL.abs0/G.D0);      % [1/s] linearised friction parameter in alongshore direction
      sigma            = kappa./C.w;                           % [-]   relation between friction and inertia
        
   %% General
   
      k                = i*C.k0.*        (1 - 1i*sigma).^0.5;  % [-] Alongshore variation
      m                = (C.f./C.c0).*1./(1 - 1i*sigma).^0.5;  % [-] Cross-shore variation
      
   %% Water level
      
      ETA.complex      = F.eta0.*exp(  G.coast.x.*m ...
                                     - G.coast.y.*k ...
                                     + 1i*C.w.*T.t0...
                                     + i*F.alpha) ;            % [m]   water level
      ETA.abs          = abs  (ETA.complex);                   % [m/s] amplitude of velocity
      ETA.arg          = angle(ETA.complex);                   % [rad] phase of velocity
   
   %% Velocity
      
      VEL.complex      = ETA.complex.*      (C.g*k./(1i*C.w + kappa));  % [m/s] velocity
      VEL.abs          = ETA.abs    .* abs  (C.g*k./(1i*C.w + kappa));  % [m/s] amplitude of velocity
      VEL.arg          = ETA.arg     + angle(C.g*k./(1i*C.w + kappa));  % [rad] phase of velocity
      
     
      OPT.v_residue         = abs(VEL.abs-VEL.abs0);
       
      if OPT.plot_iteration
   
         subplot(1,2,1)
         surfcorcen(G.coast.x,G.coast.y,VEL.abs,[.5 .5 .5])
         view(220,40)
         title(['Velocity, max velocity residue: ',num2str(max(OPT.v_residue(:))),' > limit of ',num2str(OPT.v_residue_min)])
   
         subplot(1,2,2)
         surfcorcen(G.coast.x,G.coast.y,ETA.abs,[.5 .5 .5])
         view(220,40)
         title(['Water level, iteration :',num2str(OPT.n_iterations)])
         
         disp('Press key to continue')
         pause
      end
       
   end;

%% Water level gradient

   ETA.complex_d_eta_d_y = ETA.complex.*   (-k);  % [m/m] water level gradient
   ETA.abs_d_eta_d_y     = ETA.abs.*  abs  (-k);  % [m/m] amplitude of water level gradient
   ETA.arg_d_eta_d_y     = ETA.arg +  angle(-k);  % [rad] phase of water level gradient
   
   VEL = rmfield(VEL,'abs0');
   
   VEL.k     = k;
   VEL.m     = m;
   VEL.kappa = kappa;
   VEL.sigma = sigma;
   
   ETA.k     = k;
   ETA.m     = m;
   ETA.kappa = kappa;
   ETA.sigma = sigma;
   
   if nargout==1
      varargout = {ETA};
   elseif nargout== 2
      varargout = {ETA, VEL};
   end

%% EOF