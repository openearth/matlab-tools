function XB = XBeach_1D(varargin)
%XBEACH_1D  generate XB-structure for cross-shore XBeach calculation
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
% $HeadURL$
% $Keywords:

%%
XB = CreateEmptyXBeachVar(...
    'xInitial', [],...
    'zInitial', [],...
    'dx', 5,...
    'dy', 5,...
    'ny', 2,...
    'zs0', [],...
    'depfile', 'bath.dep',...
    'tstart', 0,...
    'tint', 0,...
    'tstop', 0,...
    'nonh', [],...
    'tideloc', 0,...
    'eps', 1e-4,...
    'bcfile', 'boundarylist.lst',...
    'dir0', [],...
    'instat', 4,...
    'hmin', .5,...
    'rt', [],...
    'dthc', [],...
    'rt', [],...
    'D50', 225e-6,...
    'D90', [],...
    'hswitch', .3,...
    'dryslp', 5,...
    'OutVars', {'dims','zb'});

if ~strcmp(varargin, 'D90')
    XB.settings.SedInput.D90 = XB.settings.SedInput.D50 * 1.5;
end

%%
[XB.Input.xInitial, XB.Input.zInitial] = checkCrossShoreProfile(XB.Input.xInitial, XB.Input.zInitial,...
    'poslndwrd', 1,...
    'x_origin', 'seaside');
XB.settings.Grid.nx = length(min(XB.Input.xInitial):XB.settings.Grid.dx:max(XB.Input.xInitial))-1;
XB.settings.SedInput.morstart = XB.settings.Flow.tint;

fid = fopen(XB.settings.Waves.bcfile, 'w');
fprintf(fid, 'FILELIST\n%g   0.5   jonswap.inp', XB.settings.Flow.tstop);
fclose(fid);

fid = fopen('jonswap.inp', 'w');
fprintf(fid, 'Hm0       = %g\nfp        = %g\nmainang   = 270\ngammajsp  = 1\ns         = 10000\nfnyq      = 1', Hsig_t, 1/Tp_t);
fclose(fid);