function XB = XBeach_1D(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, T, morfac)
% XBEACH_1D  generate XB-structure for cross-shore XBeach calculation
%
%
%
% syntax:
% XB = XBeach_1D(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, T, morfac)
%
% input:
%
% output:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$ 
% $Date$
% $Author$
% $Revision$

%%
XB = CreateEmptyXBeachVar;

[XB.Input.xInitial, XB.Input.zInitial] = checkCrossShoreProfile(xInitial, zInitial,...
    'x_direction', 1,...
    'x_origin', 'seaside');

XB.settings.Grid.dx = 5;
XB.settings.Grid.dy = 5;
XB.settings.Grid.nx = length(min(XB.Input.xInitial):XB.settings.Grid.dx:max(XB.Input.xInitial))-1;
XB.settings.Grid.ny = 2;

XB.settings.Flow.zs0 = WL_t;
XB.settings.Grid.depfile = 'bath.dep';
XB.settings.Flow.tstart = 0;
XB.settings.Flow.tint = T*3600/morfac*1/18;
XB.settings.Flow.tstop = T*3600/morfac*19/18;
XB.settings.Flow.nonh = [];
XB.settings.Flow.tideloc = 0;
XB.settings.Flow.eps = .0001;

XB.settings.Waves.bcfile = 'boundarylist.lst';
fid = fopen(XB.settings.Waves.bcfile, 'w');
fprintf(fid, 'FILELIST\n%g   0.5   jonswap.inp', XB.settings.Flow.tstop);
fclose(fid);
fid = fopen('jonswap.inp', 'w');
fprintf(fid, 'Hm0       = %g\nfp        = %g\nmainang   = 270\ngammajsp  = 1\ns         = 10000\nfnyq      = 1', Hsig_t, 1/Tp_t);
fclose(fid);
XB.settings.Waves.dir0 = [];
XB.settings.Waves.hmin = .5;
XB.settings.Waves.instat = 4;
XB.settings.Waves.rt = [];
XB.settings.Waves.dthc = [];

XB.settings.SedInput.D50 = D50;
XB.settings.SedInput.D90 = 1.5*D50;
XB.settings.SedInput.morstart = XB.settings.Flow.tint;
XB.settings.SedInput.dryslp = 5;
XB.settings.SedInput.hswitch = .3;

XB.settings.OutputOptions.OutVars = {'dims','zb'};
XB.settings.OutputOptions.nglobalvar = length(XB.settings.OutputOptions.OutVars);