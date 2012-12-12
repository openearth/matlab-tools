function main(varargin)
%DELFT3D_KELVIN_WAVE.MAIN    MAIN SCRIPT for harmonic kelvin wave OBC 
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

   OPT.grdlayout   = 33;
   OPT.debug       = 0;
   OPT.x           = [];
   OPT.y           = [];
   OPT.d_sea       = [];

%% Define a delft3d grid

   if isempty(OPT.x)
   [OPT,G] = delft3d_kelvin_wave.grids(OPT);
   end

%% Physics settings for kelvin wave

   [F,  C] = delft3d_kelvin_wave.input(OPT.d_sea);

%% Calculate harmonic response in entire basin

   for ifreq=1:length(C.Tt)
      [ETA0(ifreq), VEL0(ifreq)] = delft3d_kelvin_wave.calculation(OPT.x,OPT.y, OPT.d_sea, F, C, ifreq);
   end

%% Plot tidal results in entire basin

   if OPT.debug
      delft3d_kelvin_wave.plot      (OPT.x,OPT.y, ETA0, VEL0,C);
      figure
      delft3d_kelvin_wave.ampphase  (OPT.x,OPT.y, ETA0, VEL0);
      T.t = (0:0.5:12).*3600;
      delft3d_kelvin_wave.tidalcycle(OPT.x,OPT.y, F, C, T, ETA0, VEL0);
   end

%% Save results to Delft3D basin on boundary location definitions in delft3d_kelvin_wave.grids

   delft3d_kelvin_wave.save2bch(OPT,G,ETA0,VEL0,C)

%% EOF