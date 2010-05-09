%DELFT3D_KELVIN_WAVE_MAIN    MAIN SCRIPT for harmonic kelvin wave OBC 
%
% For documentation please refer to:
%
% * Jacobs, Walter, 2004. Modelling the Rhine River Plume 
%   MSc. thesis, TU Delft, Civil Engineering.
%   http://resolver.tudelft.nl/uuid:cf8e752d-7ba7-4394-9a94-2b73e14f9949
% * de Boer, G.J. 2009. On the interaction between tides and
%   stratification in the Rhine Region of Freshwater Influence
%   PhD thesis TU Delft, Civil Engineering (chapter 3).
%   http://resolver.tudelft.nl/uuid:c5c07865-be69-4db2-91e6-f675411a4136
% * de Boer, G.J., Pietrzak, J.D., & Winterwerp, J.C. 2006. On the 
%   vertical structure of the Rhine region of freshwater influence
%   Ocean Dynamics, Vol. 56, 3-4, 198-216, special issue PECS 2004 
%   (doi:10.1007/s10236-005-0042-1)
%   http://dx.doi.org/10.1007/s10236-005-0042-1
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

%% Note the redundant 0 on the 1st line of the resulting *.bch

%% Initialize

   U.workdir     = [pwd filesep 'delft3d_kelvin_wave_test' filesep];
   U.grd         = '155x235.grd'; % [130x210] + 25 stretch
   U.bnd         = '155x235_0.bnd';
   U.gridoption  = 33; % in d3d_grd_square_basin

   U.Neumann     = 0; % 1 = modifies Riemann boundary to Neumann boundary
   U.R0          = 1; % 1 = modifies Riemann boundary to zero Riemann boundary
   U.U0          = 0; 
   U.writebch    = 1;
   U.writeini    = 1;
   U.debug       = 0;

   disp(U)

%% Generate harmonic boundary data

   G               = delft3d_kelvin_wave_grids(U.gridoption); %[U.workdir,U.grd])
   G.base.x        =   -2250;
   G.base.y        = -725671;
   G.base.y        =   250;
   G.angle         = 0;
   G.D0            = 20;

   [G, F, C   ]    = delft3d_kelvin_wave_input(G);

   U.bchfilename   = ['Depth_',num2str(G.D0),'_ks_',num2str(C.Ks),'_amplitudes_',num2str(F.eta0),'.bch'];

   for ifreq=1:length(C.Tt)
      [ETA0(ifreq), VEL0(ifreq)] = delft3d_kelvin_wave_calculation(G, F, C,ifreq);
   end

%% Plot tidal results

    if U.debug
       delft3d_kelvin_wave_plot      (G, ETA0, VEL0,C);
       figure
       delft3d_kelvin_wave_ampphase  (G, ETA0, VEL0);
       T.t = (0:0.5:12).*3600;
       delft3d_kelvin_wave_tidalcycle(G, F, C, T, ETA0, VEL0);
    end

%% Save harmonic boundary data in Delft3D format

   BND = delft3d_io_bnd('read',[U.workdir,U.bnd],G.mmax,G.nmax);

   BCH.amplitudes  = zeros(2,BND.NTables,length(C.w));
   BCH.phases      = zeros(2,BND.NTables,length(C.w));

   % now add the constant offset
   BCH.frequencies = [0 360./C.Tt.*3600]; % [s] to [deg/hour]
   BCH.a0          = zeros(2,BND.NTables,1                      );

   for ifreq = 1:length(find(~(BCH.frequencies)==0))

      for i=1:BND.NTables

         if strcmp('Z',upper(BND.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));

         elseif strcmp('R',upper(BND.DATA(i).bndtype)) & U.Neumann

            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4)));

         elseif strcmp('R',upper(BND.DATA(i).bndtype)) & U.R0

            BCH.amplitudes(1,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4)));


         elseif strcmp('R',upper(BND.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  =      0.*(VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2))) + ...
                                              0.*(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  =      0.*(VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4))) + ...
                                              0.*(ETA0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));

         elseif strcmp('C',upper(BND.DATA(i).bndtype)) & U.U0;

            BCH.amplitudes(1,i,ifreq)  = 0.*      VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  = 0.*      VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));

         elseif strcmp('C',upper(BND.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));

         end

      end % for i=1:BND.NTables

   end % for ifreq = length(BCH.frequencies)

   if U.writebch
      ok=delft3d_io_bch('write',[U.workdir,U.bchfilename],BCH);
   end

   % DOES NOT WORK, ADD ALL SPECTRAL COMPONENTS FIRST
   %if U.writeini
   %ok=delft3d_io_ini('write',[U.workdir,'kelvin',num2str(G.D,'%.3i'),'.ini'],addrowcol(real      (ETA0.complex ),0),...
   %                                                                          addrowcol(zeros(size(ETA0.complex)),0),...
   %                                                                          addrowcol(real      (VEL0.complex ),0));
   %end                                                                  

%% EOF